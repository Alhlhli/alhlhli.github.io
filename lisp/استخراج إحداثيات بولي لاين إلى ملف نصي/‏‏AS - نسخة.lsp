;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: PLC
;;; الملف الأصلي: ‏‏AS - نسخة.lsp
;; PL2CSV - Export Polyline vertices (X,Y) to comma-separated TXT
;; يدعم: LWPOLYLINE و 2D/3D POLYLINE
;; يحفظ الإحداثيات بصيغة: X,Y لكل سطر
(defun c:PL2CSV (/ ss fn fh prec n i en obj on pts)

  (vl-load-com)

  ;; تنسيق رقم بعدد منازل عشرية
  (defun _fmt (x p) (rtos x 2 p))

  ;; جلب نقاط رؤوس LWPolyline عبر المعاملات (params)
  (defun _lwpts (vlaObj / end last i p acc)
    (setq end  (vlax-curve-getEndParam vlaObj)
          last (if (vla-get-Closed vlaObj) (1- end) end)
          i    0
          acc  '()
    )
    (while (<= i last)
      (setq p   (vlax-curve-getPointAtParam vlaObj i)
            acc (cons p acc)
            i   (1+ i)
      )
    )
    (reverse acc)
  )

  ;; جلب نقاط رؤوس Polyline (القديمة 2D/3D) من كيانات VERTEX
  (defun _plpts (ename / v pts d pt)
    (setq v (entnext ename) pts '())
    (while (and v (/= (cdr (assoc 0 (entget v))) "SEQEND"))
      (setq d  (entget v)
            pt (cdr (assoc 10 d))
            ;; تحويل من نظام الكيان إلى WCS لثبات النتائج
            pt (trans pt ename 0)
            pts (cons pt pts)
            v (entnext v)
      )
    )
    (reverse pts)
  )

  ;; اختيار البوليلينات
  (setq ss (ssget "_:L" '((0 . "LWPOLYLINE,POLYLINE"))))
  (if (not ss)
    (progn (princ "\nلم يتم اختيار أي Polyline.") (princ))
    (progn
      ;; ملف الإخراج
      (setq fn (getfiled "اختر/اكتب اسم ملف TXT" (getvar "DWGPREFIX") "txt" 1))
      (if (not fn)
        (progn (princ "\nتم الإلغاء.") (princ))
        (progn
          ;; دقة الكسور العشرية
          (setq prec (getint "\nعدد المنازل العشرية [الافتراضي 3]: "))
          (if (not prec) (setq prec 3))

          (setq fh (open fn "w"))
          (if (not fh)
            (princ "\nتعذّر فتح الملف للكتابة.")
            (progn
              ;; معالجة كل بوليلان
              (setq n (sslength ss) i 0)
              (while (< i n)
                (setq en (ssname ss i)
                      obj (vlax-ename->vla-object en)
                      on  (vla-get-ObjectName obj)
                )
                (cond
                  ((= on "AcDbPolyline")
                   (setq pts (_lwpts obj))
                  )
                  ((or (= on "AcDb2dPolyline") (= on "AcDb3dPolyline"))
                   (setq pts (_plpts en))
                  )
                  (t (setq pts nil))
                )
                ;; كتابة X,Y لكل نقطة
                (foreach p pts
                  (write-line
                    (strcat (_fmt (car  p) prec) "," (_fmt (cadr p) prec))
                    fh
                  )
                )
                (setq i (1+ i))
              )
              (close fh)
              (princ (strcat "\nتم التصدير إلى: " fn))
            )
          )
        )
      )
    )
  )
  (princ)
)

;;; اختصار من ثلاثة أحرف.
(defun c:PLC () (c:PL2CSV))
