;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: SUM
;;; الملف الأصلي: ‏‏SUMT - نسخة (7).LSP
;; =================================================================================
;; اسم الأمر: SUMT
;; الوظيفة: حصر متكامل (أطوال، أبعاد، نصوص) مع واجهة اختيار وطرق إخراج متعددة.
;; م/ عامر - المكتب الفني
;; =================================================================================

(defun c:SUMT (/ dcl_id choice out_type show_eqn ss total i elst val val-list unique-list pt dcl_file f table space row final-str filter)
  (vl-load-com)
  (setq total 0.0 val-list '())

  ;; 1. إنشاء ملف الواجهة (DCL) برمجياً
  (setq dcl_file (vl-filename-mktemp "sum.dcl"))
  (setq f (open dcl_file "w"))
  (write-line "sum_dialog : dialog { label = \"أداة الحصر المتقدمة - المكتب الفني\";" f)
  (write-line " : column { : radio_column { key = \"type_sel\"; label = \"1. نوع العناصر:\";" f)
  (write-line " : radio_button { key = \"dim\"; label = \"أبعاد فقط (Dimensions)\"; value = \"1\"; }" f)
  (write-line " : radio_button { key = \"txt\"; label = \"نصوص (Text/MText)\"; }" f)
  (write-line " : radio_button { key = \"all\"; label = \"الكل (أبعاد ونصوص)\"; } }" f)
  (write-line " : spacer { height = 1; }" f)
  (write-line " : radio_column { key = \"out_sel\"; label = \"2. طريقة الإخراج:\";" f)
  (write-line " : radio_button { key = \"res_txt\"; label = \"نص إجمالي (Text)\"; value = \"1\"; }" f)
  (write-line " : radio_button { key = \"res_tbl\"; label = \"جدول تفصيلي (Table)\"; } }" f)
  (write-line " : spacer { height = 0.5; }" f)
  (write-line " : toggle { key = \"show_eqn\"; label = \"إظهار تفاصيل المعادلة (1+2=3)\"; value = \"0\"; }" f)
  (write-line " : spacer { height = 1; }" f)
  (write-line " : row { : button { key = \"accept\"; label = \"موافق\"; is_default = true; }" f)
  (write-line " : button { key = \"cancel\"; label = \"إلغاء\"; is_cancel = true; } } } }" f)
  (close f)

  ;; 2. تشغيل الواجهة
  (setq dcl_id (load_dialog dcl_file))
  (if (not (new_dialog "sum_dialog" dcl_id)) (exit))
  (action_tile "accept" "(setq choice (get_tile \"type_sel\") out_type (get_tile \"out_sel\") show_eqn (get_tile \"show_eqn\")) (done_dialog)")
  (start_dialog)
  (unload_dialog dcl_id)
  (vl-file-delete dcl_file)

  ;; 3. معالجة البيانات بناءً على الاختيار
  (if choice
    (progn
      (setq filter (cond ((= choice "txt") '((0 . "TEXT,MTEXT")))
                         ((= choice "dim") '((0 . "DIMENSION")))
                         (t '((0 . "TEXT,MTEXT,DIMENSION")))))

      (princ "\nاختر العناصر المراد حصرها: ")
      (if (setq ss (ssget filter))
        (progn
          (repeat (setq i (sslength ss))
            (setq elst (entget (ssname ss (setq i (1- i)))))
            ;; استخراج القيمة سواء كانت بعداً أو نصاً رقمياً
            (setq val (if (wcmatch (cdr (assoc 0 elst)) "DIMENSION")
                        (cdr (assoc 42 elst))
                        (atof (cdr (assoc 1 elst)))))
            (if (and val (/= val 0.0))
                (setq val-list (cons (rtos val 2 2) val-list) 
                      total (+ total val))))

          (if val-list
            (progn
              (setq pt (getpoint "\nحدد نقطة إدراج النتيجة: "))
              (if pt
                (cond 
                  ;; الخيار الأول: إنشاء جدول أوتوكاد
                  ((= out_type "res_tbl")
                    (setq unique-list '())
                    (foreach x val-list
                      (if (setq item (assoc x unique-list))
                        (setq unique-list (subst (cons x (1+ (cdr item))) item unique-list))
                        (setq unique-list (cons (cons x 1) unique-list))))
                    
                    (setq space (vla-get-modelspace (vla-get-activedocument (vlax-get-acad-object))))
                    (setq table (vla-addtable space (vlax-3d-point pt) (+ (length unique-list) 3) 4 1.5 15.0))
                    (vla-settext table 0 0 "تقرير الحصر المتقدم")
                    (vla-settext table 1 0 "القيمة") (vla-settext table 1 1 "التكرار")
                    (vla-settext table 1 2 "الإجمالي") (vla-settext table 1 3 "ملاحظات")
                    (setq row 2)
                    (foreach x (vl-sort unique-list '(lambda (a b) (< (atof (car a)) (atof (car b)))))
                      (vla-settext table row 0 (car x))
                      (vla-settext table row 1 (itoa (cdr x)))
                      (vla-settext table row 2 (rtos (* (atof (car x)) (cdr x)) 2 2))
                      (setq row (1+ row)))
                    (vla-settext table row 0 "الإجمالي الكلي")
                    (vla-settext table row 2 (rtos total 2 2))
                    (princ "\nتم إنشاء الجدول بنجاح.")
                  )

                  ;; الخيار الثاني: إخراج نص
                  ((= out_type "res_txt")
                    (if (= show_eqn "1")
                      (progn
                        (setq final-str "")
                        (foreach n (reverse val-list)
                          (setq final-str (if (= final-str "") n (strcat final-str "+" n))))
                        (setq final-str (strcat final-str " = " (rtos total 2 2))))
                      (setq final-str (strcat "Total: " (rtos total 2 2))))
                    
                    (entmake (list '(0 . "TEXT") (cons 10 pt) (cons 40 (getvar "TEXTSIZE")) (cons 1 final-str)))
                  )
                )
              )
            )
            (princ "\nلا توجد قيم رقمية صالحة في العناصر المختارة.")
          )
        )
        (princ "\nلم يتم اختيار أي عناصر.")
      )
    )
  )
  (princ)
)

(princ "\n[SUMT] تم تحميل ليسب الحصر. اكتب SUMT للبدء.")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:SUM () (c:SUMT))
