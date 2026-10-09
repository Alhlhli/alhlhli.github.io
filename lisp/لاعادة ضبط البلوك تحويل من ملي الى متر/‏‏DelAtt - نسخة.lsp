;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: FBR
;;; الملف الأصلي: ‏‏DelAtt - نسخة.lsp
(defun c:FixBlockReset (/ ss i ename obj bname bdef processedBlocks doc)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq processedBlocks '()) ; قائمة لتتبع البلوكات التي تم تعديل محتواها
  
  (princ "\nاختر البلوكات (سيتم تحويل السكيل من 0.001 إلى 1): ")
  (if (setq ss (ssget '((0 . "INSERT"))))
    (progn
      (vla-StartUndoMark doc)
      (repeat (setq i (sslength ss))
        (setq ename (ssname ss (setq i (1- i))))
        (setq obj (vlax-ename->vla-object ename))
        (setq bname (vla-get-EffectiveName obj))
        
        ;; 1. تعديل محتوى تعريف البلوك داخلياً (مرة واحدة لكل نوع)
        (if (not (member bname processedBlocks))
          (progn
            (setq bdef (vla-item (vla-get-Blocks doc) bname))
            (vlax-for ent bdef
              (vl-catch-all-apply 'vla-ScaleEntity (list ent (vlax-3d-point '(0 0 0)) 0.001))
            )
            (vl-catch-all-apply 'vla-put-units (list bdef 6)) ; تحويل التعريف لمتر
            (setq processedBlocks (cons bname processedBlocks))
          )
        )

        ;; 2. تحديث المقياس الخارجي للمرجع المختار ليصبح 1.0
        (vla-put-XScaleFactor obj 1.0)
        (vla-put-YScaleFactor obj 1.0)
        (vla-put-ZScaleFactor obj 1.0)
      )
      (vla-EndUndoMark doc)
      (vla-Regen doc acAllViewports)
      (princ (strcat "\nتم التعديل بنجاح. سكيل الخصائص الآن: 1.0"))
    )
    (princ "\nلم يتم اختيار بلوكات.")
  )
  (princ)
)
;;; اختصار من ثلاثة أحرف.
(defun c:FBR () (c:FixBlockReset))
