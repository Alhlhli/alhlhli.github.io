;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: MBG
;;; الملف الأصلي: MergeByGeo.LSP
(defun c:MergeByGeo (/ doc blocks blkList signatures masterList blkName ent count sig masterName i ss targetEnt)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (setq blocks (vla-get-Blocks doc))
  
  (princ "\nجاري تحليل هندسة البلوكات... قد يستغرق ذلك وقتاً حسب حجم الملف.")
  
  ;; قائمة لتخزين البصمات: ( (Signature . BlockName) ... )
  (setq signatures '())
  (setq masterList '()) ;; لتتبع ما تم استبداله

  ;; 1. المرور على جميع تعريفات البلوكات
  (vlax-for blk blocks
    (setq blkName (vla-get-Name blk))
    
    ;; استثناء بلوكات النظام والـ Xrefs
    (if (and (= (vla-get-IsXref blk) :vlax-false)
             (= (vla-get-IsLayout blk) :vlax-false)
             (/= (substr blkName 1 1) "*"))
      (progn
        ;; --- إنشاء بصمة للبلوك ---
        ;; البصمة تعتمد على عدد العناصر وأنواعها
        (setq sig "")
        (setq count 0)
        (vlax-for ent blk
           (setq sig (strcat sig (vla-get-ObjectName ent)))
           (setq count (1+ count))
        )
        ;; نضيف عدد العناصر للبصمة لزيادة الدقة
        (setq sig (strcat (itoa count) "-" sig))
        
        ;; إذا كان البلوك فارغاً لا نعالجه
        (if (> count 0)
            (setq signatures (cons (cons sig blkName) signatures))
        )
      )
    )
  )

  ;; 2. تجميع البلوكات المتشابهة
  ;; سنقوم بفرز القائمة والبحث عن البصمات المكررة
  
  (princ "\nجاري الدمج...")
  (setq count 0)
  
  ;; ترتيب القائمة ليسهل المقارنة ولكن سنستخدم طريقة البحث المباشر
  (while signatures
    (setq currentPair (car signatures))
    (setq currentSig (car currentPair))
    (setq currentName (cdr currentPair))
    
    ;; البحث عن كل البلوكات التي لها نفس البصمة في باقي القائمة
    (setq matches (vl-remove-if-not '(lambda (x) (= (car x) currentSig)) signatures))
    
    ;; إذا وجدنا أكثر من بلوك بنفس البصمة
    (if (> (length matches) 1)
      (progn
        ;; اختيار "الأصل" (سنختار الاسم الأقصر ليكون هو المعتمد)
        (setq masterName (cdr (car matches)))
        (foreach m matches
           (if (< (strlen (cdr m)) (strlen masterName))
               (setq masterName (cdr m))
           )
        )

        ;; استبدال الجميع بالماستر
        (foreach m matches
           (setq targetName (cdr m))
           (if (/= targetName masterName)
             (progn
                ;; البحث عن البلوكات في الرسم واستبدالها
                (setq ss (ssget "X" (list '(0 . "INSERT") (cons 2 targetName))))
                (if ss
                   (progn
                     (setq i 0)
                     (repeat (sslength ss)
                        (setq targetEnt (vlax-ename->vla-object (ssname ss i)))
                        (vla-put-Name targetEnt masterName) ;; تغيير الاسم
                        (setq i (1+ i))
                     )
                     (setq count (1+ count))
                     (princ (strcat "\nتم دمج: " targetName " --> " masterName))
                   )
                )
             )
           )
        )
      )
    )
    
    ;; إزالة هذه المجموعة من القائمة لمتابعة البقية
    (setq signatures (vl-remove-if '(lambda (x) (= (car x) currentSig)) signatures))
  )

  (princ (strcat "\nتمت العملية. عدد عمليات الدمج: " (itoa count)))
  (princ "\nيرجى عمل PURGE.")
  (princ)
)
;;; اختصار من ثلاثة أحرف.
(defun c:MBG () (c:MergeByGeo))
