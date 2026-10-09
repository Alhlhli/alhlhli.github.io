;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: MTX
;;; الملف الأصلي: JoinText(MTX).lsp
;;; ===========================================================================
;;; أداة دمج النصوص المتقاربة في أوتوكاد
;;; Command: MTX
;;; ===========================================================================

(defun c:MTX (/ ss dist i ent elst p pts data sorted result current next ans sep)
  (vl-load-com)

  ;; 1. طلب مسافة التسامح من المستخدم
  (setq dist (getdist "\nحدد المسافة القصوى للدمج (Tolerance) <1.0>: "))
  (if (not dist) (setq dist 1.0))

  ;; 2. سؤال المستخدم عن المسافة بين النصوص مع تحسين ظهور الخيارات
  ;; استخدام رقم 1 في initget يجعل الإجابة إجبارية، ولكن سنتركه اختيارياً للسماح بالـ Default
  (initget "Yes No")
  (setq ans (getkword "\nهل تريد إضافة مسافة بين النصوص؟ [نعم(Yes)/لا(No)] <Yes>: "))
  
  ;; معالجة الخيار المختار (الافتراضي هو نعم)
  (if (or (null ans) (= ans "Yes"))
    (setq sep " ") ; إضافة مسافة
    (setq sep "")  ; دمج مباشر بدون مسافة
  )

  ;; 3. اختيار النصوص
  (prompt "\nاختر النصوص المراد دمجها (TEXT or MTEXT): ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))

  (if ss
    (progn
      (setq i 0)
      (setq data '())

      ;; 4. استخراج البيانات (النص، الإحداثيات، الكائن)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq elst (entget ent))
        (setq p (cdr (assoc 10 elst))) ; نقطة الإدراج
        (setq data (cons (list p (cdr (assoc 1 elst)) ent) data))
        (setq i (1+ i))
      )

      ;; 5. ترتيب النصوص حسب الموقع (Y من الأعلى للأسفل، ثم X من اليسار لليمين)
      (setq sorted (vl-sort data 
        '(lambda (a b)
           (if (equal (cadar a) (cadar b) dist)
               (< (caar a) (caar b))
               (> (cadar a) (cadar b))
           )
         )
      ))

      ;; 6. منطقية الدمج
      (while sorted
        (setq current (car sorted))
        (setq sorted (cdr sorted))
        
        (setq next (car sorted))
        ;; فحص المسافة بين النص الحالي والنص التالي
        (if (and next (<= (distance (car current) (car next)) dist))
          (progn
            ;; دمج النص وحذف الكائن التالي باستخدام الفاصل المختار (sep)
            (setq new_str (strcat (nth 1 current) sep (nth 1 next)))
            (setq new_pt (car current))
            (setq new_ent (nth 2 current))
            
            ;; تحديث الكائن الحالي في الأوتوكاد
            (entmod (subst (cons 1 new_str) (assoc 1 (entget new_ent)) (entget new_ent)))
            
            ;; حذف الكائن الذي تم دمج نصّه
            (entdel (nth 2 next))
            
            ;; إعادة الكائن المحدث للقائمة للمقارنة مع التالي
            (setq sorted (cons (list new_pt new_str new_ent) (cdr sorted)))
          )
        )
      )
      (princ "\nتمت عملية الدمج بنجاح.")
    )
    (princ "\nلم يتم اختيار أي نصوص.")
  )
  (princ)
)

(princ "\nتم تحميل أداة دمج النصوص. اكتب MTX لتشغيلها.")
(princ)