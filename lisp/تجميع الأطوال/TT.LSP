;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: TT
;;; الملف الأصلي: TT.LSP
;;; ========================================================================
;;; اسم الأمر: TT
;;; الوصف: حصر أطوال العناصر وإدراجها في جدول أوتوكاد
;;; المبرمج: Gemini (Custom for Eng. Amer)
;;; ========================================================================

(defun c:TT (/ ss i ent obj etype len 
                 line-len poly-len arc-len circ-len spline-len ellip-len total-len
                 pt table row)
  (vl-load-com)
  
  ;; تهيئة المتغيرات
  (setq line-len 0.0 poly-len 0.0 arc-len 0.0 circ-len 0.0 spline-len 0.0 ellip-len 0.0 total-len 0.0)

  ;; اختيار العناصر من قبل المستخدم
  (princ "\nإختر العناصر لحصر أطوالها (Lines, Polylines, Arcs, Circles, Splines, Ellipses): ")
  (if (setq ss (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE,ARC,CIRCLE,SPLINE,ELLIPSE"))))
    (progn
      (repeat (setq i (sslength ss))
        (setq ent (ssname ss (setq i (1- i)))
              obj (vlax-ename->vla-object ent)
              etype (cdr (assoc 0 (entget ent))))
        
        ;; حساب الطول بناءً على نوع العنصر
        (setq len (cond
                    ((member etype '("LINE" "LWPOLYLINE" "POLYLINE" "SPLINE" "ELLIPSE"))
                     (vlax-curve-getDistAtParam obj (vlax-curve-getEndParam obj)))
                    ((eq etype "ARC")
                     (vla-get-ArcLength obj))
                    ((eq etype "CIRCLE")
                     (vla-get-Circumference obj))
                    (t 0.0)))
        
        ;; تجميع الأطوال حسب النوع
        (cond
          ((eq etype "LINE") (setq line-len (+ line-len len)))
          ((member etype '("LWPOLYLINE" "POLYLINE")) (setq poly-len (+ poly-len len)))
          ((eq etype "ARC") (setq arc-len (+ arc-len len)))
          ((eq etype "CIRCLE") (setq circ-len (+ circ-len len)))
          ((eq etype "SPLINE") (setq spline-len (+ spline-len len)))
          ((eq etype "ELLIPSE") (setq ell-len (+ ellip-len len))))
        
        (setq total-len (+ total-len len))
      )

      ;; عرض النتائج في سطر الأوامر
      (princ (strcat "\nإجمالي الأطوال: " (rtos total-len 2 3)))

      ;; طلب مكان وضع الجدول
      (setq pt (getpoint "\nانقر في اللوحة لتحديد مكان إدراج الجدول: "))
      (if pt
        (progn
          (setq space (vla-get-modelspace (vla-get-activedocument (vlax-get-acad-object))))
          (setq table (vla-addTable space (vlax-3d-point pt) 9 2 10.0 40.0))
          
          ;; تنسيق الجدول
          (vla-setText table 0 0 "جدول حصر الأطوال (Summary)")
          (vla-setText table 1 0 "نوع العنصر")
          (vla-setText table 1 1 "إجمالي الطول")

          ;; تعبئة البيانات
          (setq data (list 
                       (list "Lines" line-len)
                       (list "Polylines" poly-len)
                       (list "Arcs" arc-len)
                       (list "Circles" circ-len)
                       (list "Splines" spline-len)
                       (list "Ellipses" ellip-len)
                       (list "Total" total-len)))
          
          (setq row 2)
          (foreach item data
            (vla-setText table row 0 (car item))
            (vla-setText table row 1 (rtos (cadr item) 2 3))
            (setq row (1+ row))
          )
          (princ "\nتم إنشاء الجدول بنجاح.")
        )
      )
    )
    (princ "\nلم يتم اختيار أي عناصر صالحة.")
  )
  (princ)
)

(princ "\nتم تحميل ليسب حصر الأطوال بنجاح. اكتب TLEN للبدء.")
(princ)