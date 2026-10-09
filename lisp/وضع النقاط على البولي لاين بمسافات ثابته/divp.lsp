;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: DIV
;;; الملف الأصلي: divp.lsp
(defun c:DIVP (/ ent opt val)
  (setq ent (car (entsel "\nاختر الخط أو البولي لاين: ")))
  (if ent
    (progn
      (initget "Distance Number")
      (setq opt (getkword "\nاختر طريقة التوزيع [Distance/Number] <Distance>: "))
      (if (not opt) (setq opt "Distance"))

      (if (= opt "Distance")
        (progn
          (setq val (getdist "\nأدخل المسافة بين النقاط: "))
          (command "_.measure" ent val)
        )
        (progn
          (setq val (getint "\nأدخل عدد الأقسام المطلوبة: "))
          (command "_.divide" ent val)
        )
      )
      (princ "\nتمت العملية بنجاح.")
    )
    (princ "\nلم يتم اختيار عنصر.")
  )
  (princ)
)
;;; اختصار من ثلاثة أحرف.
(defun c:DIV () (c:DIVP))
