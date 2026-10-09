;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: RBN
;;; الملف الأصلي: ‏‏RBN - نسخة.lsp
(defun c:RBN (/ blkEnt blkObj oldName txtEnt txtData rawName cleanName)
  (vl-load-com)

  ;; --- دالة تنظيف النص المتقدمة ---
  (defun sanitize-name (str / forbidden i char result lastWasDot)
    (setq forbidden "/\\:*?\"<>|,=; ") ; replace forbidden characters and spaces with dots
    (setq result "")
    (setq lastWasDot nil)
    (setq i 1)
    (repeat (strlen str)
      (setq char (substr str i 1))
      ;; التحقق إذا كان الحرف ممنوعاً أو مسافة
      (if (vl-string-search char forbidden)
        (progn
          (if (not lastWasDot) ; إذا لم يكن الحرف السابق نقطة، أضف نقطة
            (setq result (strcat result ".")
                  lastWasDot t)
          )
        )
        (setq result (strcat result char) ; إذا كان حرفاً عادياً، أضفه وألغِ حالة النقطة
              lastWasDot nil)
      )
      (setq i (1+ i))
    )
    ;; إزالة أي نقطة زائدة في البداية أو النهاية
    (vl-string-trim "." result)
  )

  ;; 1. طلب تحديد البلوك
  (setq blkEnt (car (entsel "\nاختر البلوك المراد تغيير اسمه: ")))
  
  (if (and blkEnt (= (cdr (assoc 0 (entget blkEnt))) "INSERT"))
    (progn
      (setq blkObj (vlax-ename->vla-object blkEnt))
      (setq oldName (vla-get-EffectiveName blkObj))

      ;; 2. طلب تحديد النص
      (setq txtEnt (car (entsel "\nاختر النص الجديد: ")))
      
      (if (and txtEnt (member (cdr (assoc 0 (entget txtEnt))) '("TEXT" "MTEXT")))
        (progn
          (setq txtData (entget txtEnt))
          (setq rawName (cdr (assoc 1 txtData)))
          
          ;; تنظيف النص مع دمج النقاط المتتالية
          (setq cleanName (sanitize-name rawName))

          ;; 3. تنفيذ عملية إعادة التسمية
          (if (and (/= cleanName "") (/= cleanName oldName))
            (if (tblsearch "BLOCK" cleanName)
              (princ (strcat "\nخطأ: الاسم [" cleanName "] موجود مسبقاً!"))
              (progn
                (vla-put-Name (vla-item (vla-get-Blocks (vla-get-ActiveDocument (vlax-get-acad-object))) oldName) cleanName)
                (princ (strcat "\nتم التغيير بنجاح إلى: " cleanName))
              )
            )
            (princ "\nالاسم الناتج فارغ أو مطاباق للاسم الحالي.")
          )
        )
        (princ "\nخطأ: لم يتم اختيار نص.")
      )
    )
    (princ "\nخطأ: لم يتم اختيار بلوك.")
  )
  (princ)
)