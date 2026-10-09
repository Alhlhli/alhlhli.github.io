;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: DAT
;;; الملف الأصلي: DelAtt.lsp
(defun c:DELATTR (/ ss i ent obj atts total count)
  ;;; حذف جميع الـ Attributes من عدة بلوكات - تحديد متعدد
  
  (vl-load-com) ; تحميل وظائف Visual LISP
  
  (princ "\nاختر البلوكات المراد حذف الـ Attributes منها: ")
  
  ; اختيار متعدد للبلوكات
  (setq ss (ssget '((0 . "INSERT"))))
  
  (if ss
    (progn
      (setq total 0)
      (setq count 0)
      (setq i 0)
      
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        
        ; التحقق إذا كان الكائن بلوك يحتوي على attributes
        (if (and (vlax-property-available-p obj 'HasAttributes)
                 (vlax-get-property obj 'HasAttributes))
          (progn
            (setq atts (vlax-invoke obj 'GetAttributes))
            
            (if (> (length atts) 0)
              (progn
                ; حذف جميع الـ Attributes
                (foreach att atts
                  (vla-delete att)
                )
                (setq total (+ total (length atts)))
                (setq count (1+ count))
              )
            )
          )
        )
        
        (setq i (1+ i))
      )
      
      ; عرض النتائج
      (cond
        ((> total 0)
         (princ (strcat "\nتم حذف " (itoa total) " attributes من " (itoa count) " بلوك."))
        )
        ((> i 0)
         (princ "\nالبلوكات المحددة لا تحتوي على attributes.")
        )
        (t
         (princ "\nلم يتم العثور على بلوكات تحتوي على attributes.")
        )
      )
    )
    (princ "\nلم يتم اختيار أي بلوك.")
  )
  
  (princ)
)
;;; اختصار من ثلاثة أحرف.
(defun c:DAT () (c:DELATTR))
