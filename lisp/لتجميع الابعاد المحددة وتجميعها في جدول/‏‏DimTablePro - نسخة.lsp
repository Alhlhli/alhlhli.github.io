;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: DDT
;;; الملف الأصلي: ‏‏DimTablePro - نسخة.lsp
;; ============================================================
;;  DimTablePro / ddt — حصر الأبعاد بجدول متناسق هندسياً
;;  الأمر: ddt
;; ============================================================

(vl-load-com)

;; ثوابت جداول أوتوكاد لضمان التوافق
(setq acTitleRow 1
      acHeaderRow 2
      acDataRow 4
      acMiddleCenter 5)

(defun DTP:write-dcl (dcl-file / f)
  (setq f (open dcl-file "w"))
  (foreach line (list
    "DimTableProDlg : dialog {"
    "  label = \"DimTablePro - حصر الأبعاد وإنشاء الجدول\";"
    "  : boxed_row {"
    "    label = \"الإعدادات الأساسية\";"
    "    : boxed_column {"
    "      label = \"اللغة\";"
    "      : radio_button { key = \"rb_ar\"; label = \"العربية\"; }"
    "      : radio_button { key = \"rb_en\"; label = \"English\"; }"
    "    }"
    "    : boxed_column {"
    "      label = \"طريقة الاختيار\";"
    "      : radio_button { key = \"rb_man\"; label = \"يدوي (Manual)\"; }"
    "      : radio_button { key = \"rb_lay\"; label = \"طبقة (Layer)\"; }"
    "    }"
    "    : boxed_column {"
    "      label = \"ترتيب النتائج\";"
    "      : radio_button { key = \"rb_asc\";  label = \"تصاعدي\"; }"
    "      : radio_button { key = \"rb_desc\"; label = \"تنازلي\"; }"
    "    }"
    "  }"
    "  : boxed_column {"
    "    label = \"إعدادات وتحجيم الجدول\";"
    "    : row {"
    "      : edit_box { key = \"eb_txth\";  label = \"ارتفاع النص (0 = تلقائي) :\"; edit_width = 6; }"
    "      : edit_box { key = \"eb_prec\";  label = \"خانات عشرية :\";              edit_width = 4; }"
    "      : edit_box { key = \"eb_colw\";  label = \"معامل عرض الأعمدة :\";        edit_width = 4; }"
    "    }"
    "    : row {"
    "      : edit_box { key = \"eb_layer\"; label = \"اسم الطبقة :\";   edit_width = 16; }"
    "      : edit_box { key = \"eb_csv\";   label = \"اسم ملف CSV :\";  edit_width = 14; }"
    "    }"
    "  }"
    "  : boxed_column {"
    "    label = \"عناوين الجدول\";"
    "    : row {"
    "      : edit_box { key = \"eb_htitle\"; label = \"عنوان الجدول :\";    edit_width = 20; }"
    "      : edit_box { key = \"eb_hdim\";   label = \"عمود البعد :\";      edit_width = 10; }"
    "    }"
    "    : row {"
    "      : edit_box { key = \"eb_hqty\";   label = \"عمود التكرار :\";    edit_width = 10; }"
    "      : edit_box { key = \"eb_htot\";   label = \"عمود الاجمالي :\";   edit_width = 10; }"
    "      : edit_box { key = \"eb_hgrand\"; label = \"الاجمالي الكلي :\";  edit_width = 10; }"
    "    }"
    "  }"
    "  : boxed_column {"
    "    label = \"الخيارات\";"
    "    : row {"
    "      : toggle { key = \"ck_excel\"; label = \"تصدير الى Excel (CSV)\"; }"
    "      : toggle { key = \"ck_mark\";  label = \"تمييز الابعاد بلون\"; }"
    "      : toggle { key = \"ck_total\"; label = \"صف الاجمالي الكلي\"; }"
    "      : toggle { key = \"ck_layer\"; label = \"انشاء طبقة الجدول\"; }"
    "    }"
    "    : row {"
    "      : text { label = \"لون التمييز :\"; alignment = right; }"
    "      : radio_button { key = \"rb_c1\"; label = \"احمر\"; }"
    "      : radio_button { key = \"rb_c2\"; label = \"اصفر\"; }"
    "      : radio_button { key = \"rb_c3\"; label = \"اخضر\"; }"
    "      : radio_button { key = \"rb_c4\"; label = \"سماوي\"; }"
    "      : radio_button { key = \"rb_c5\"; label = \"ازرق\"; }"
    "      : radio_button { key = \"rb_c6\"; label = \"بنفسجي\"; }"
    "      : radio_button { key = \"rb_c9\"; label = \"مخصص\"; }"
    "      : edit_box { key = \"eb_color\"; label = \"رقم:\"; edit_width = 4; }"
    "    }"
    "  }"
    "  spacer;"
    "  : row {"
    "    : button { key = \"btn_ok\";     label = \"تنفيذ\";               is_default = true; width = 12; }"
    "    : button { key = \"btn_reset\";  label = \"استعادة الافتراضي\";   width = 16; }"
    "    : button { key = \"btn_cancel\"; label = \"الغاء\";               is_cancel  = true; width = 12; }"
    "  }"
    "}"
  )
    (write-line line f)
  )
  (close f)
)

;; ---------- كشف ارتفاع نص البعد الفعلي ----------
(defun DTP:get-dim-height (ename obj / blk ent found h sc)
  (if (and ename (setq blk (cdr (assoc 2 (entget ename)))))
    (progn
      (setq ent (tblobjname "BLOCK" blk))
      (while (and ent (not found))
        (setq ent (entnext ent))
        (if ent
          (if (vl-position (cdr (assoc 0 (entget ent))) '("MTEXT" "TEXT"))
            (setq h (cdr (assoc 40 (entget ent)))
                  found T)
          )
        )
      )
    )
  )
  (if (or (null h) (zerop h))
    (progn
      (setq h (vl-catch-all-apply 'vla-get-TextHeight (list obj)))
      (if (vl-catch-all-error-p h) (setq h nil))
      (if h
        (progn
          (setq sc (vl-catch-all-apply 'vla-get-ScaleFactor (list obj)))
          (if (or (vl-catch-all-error-p sc) (<= sc 0.0)) (setq sc 1.0))
          (setq h (* h sc))
        )
      )
    )
  )
  (if (or (null h) (zerop h)) (setq h (getvar "TEXTSIZE")))
  h
)

;; ---------- قراءة مدخلات الحوار ----------
(defun DTP:get-values (/ ci)
  (setq DTP:lang       (if (= (get_tile "rb_ar")  "1") "Arabic" "English"))
  (setq DTP:sel_mode   (if (= (get_tile "rb_man") "1") "Manual" "Layer"))
  (setq DTP:sort_asc   (= (get_tile "rb_asc") "1"))
  (setq DTP:txtH       (distof (get_tile "eb_txth") 2))
  (setq DTP:prec       (atoi   (get_tile "eb_prec")))
  (setq DTP:colW       (distof (get_tile "eb_colw") 2))
  (setq DTP:layer_name (get_tile "eb_layer"))
  (setq DTP:csv_name   (get_tile "eb_csv"))
  (setq DTP:h_title    (get_tile "eb_htitle"))
  (setq DTP:h_dim      (get_tile "eb_hdim"))
  (setq DTP:h_qty      (get_tile "eb_hqty"))
  (setq DTP:h_tot      (get_tile "eb_htot"))
  (setq DTP:h_grand    (get_tile "eb_hgrand"))
  (setq DTP:exp_excel  (= (get_tile "ck_excel") "1"))
  (setq DTP:mark_dim   (= (get_tile "ck_mark")  "1"))
  (setq DTP:show_total (= (get_tile "ck_total") "1"))
  (setq DTP:make_layer (= (get_tile "ck_layer") "1"))
  (setq ci
    (cond
      ((= (get_tile "rb_c1") "1") 1)
      ((= (get_tile "rb_c2") "1") 2)
      ((= (get_tile "rb_c3") "1") 3)
      ((= (get_tile "rb_c4") "1") 4)
      ((= (get_tile "rb_c5") "1") 5)
      ((= (get_tile "rb_c6") "1") 6)
      (T (atoi (get_tile "eb_color")))
    )
  )
  (if (or (null ci) (< ci 1) (> ci 256)) (setq ci 1))
  (setq DTP:dim_color ci)

  (if (null DTP:txtH) (setq DTP:txtH 0.0))
  (if (or (null DTP:prec) (< DTP:prec 0)) (setq DTP:prec 2))
  (if (or (null DTP:colW) (< DTP:colW 4.0)) (setq DTP:colW 10.0))
  (if (= DTP:layer_name "") (setq DTP:layer_name "BOQ-TABLES"))
  (if (= DTP:csv_name   "") (setq DTP:csv_name   "Dim_Report"))
  (if (= DTP:h_title "") (setq DTP:h_title "جدول حصر الابعاد"))
  (if (= DTP:h_dim   "") (setq DTP:h_dim   "البعد"))
  (if (= DTP:h_qty   "") (setq DTP:h_qty   "التكرار"))
  (if (= DTP:h_tot   "") (setq DTP:h_tot   "الاجمالي"))
  (if (= DTP:h_grand "") (setq DTP:h_grand "الاجمالي الكلي"))
)

;; ---------- استعادة الافتراضي ----------
(defun DTP:reset ()
  (set_tile "rb_ar"  "1")  (set_tile "rb_en"   "0")
  (set_tile "rb_man" "1")  (set_tile "rb_lay"  "0")
  (set_tile "rb_asc" "1")  (set_tile "rb_desc" "0")
  (set_tile "eb_txth"  "0.0")
  (set_tile "eb_prec"  "2")
  (set_tile "eb_colw"  "10.0")
  (set_tile "eb_layer" "BOQ-TABLES")
  (set_tile "eb_csv"   "Dim_Report")
  (set_tile "eb_htitle" "جدول حصر الابعاد")
  (set_tile "eb_hdim"   "البعد")
  (set_tile "eb_hqty"   "التكرار")
  (set_tile "eb_htot"   "الاجمالي")
  (set_tile "eb_hgrand" "الاجمالي الكلي")
  (set_tile "ck_excel"  "0")
  (set_tile "ck_mark"   "1")
  (set_tile "ck_total"  "1")
  (set_tile "ck_layer"  "1")
  (set_tile "rb_c1" "1")
  (set_tile "rb_c2" "0") (set_tile "rb_c3" "0")
  (set_tile "rb_c4" "0") (set_tile "rb_c5" "0")
  (set_tile "rb_c6" "0") (set_tile "rb_c9" "0")
  (set_tile "eb_color" "1")
)

;; ---------- تعيين القيم الافتراضية عند الفتح ----------
(defun DTP:set-defaults ()
  (set_tile "rb_ar"  "1")
  (set_tile "rb_man" "1")
  (set_tile "rb_asc" "1")
  (set_tile "eb_txth"  "0.0")
  (set_tile "eb_prec"  "2")
  (set_tile "eb_colw"  "10.0")
  (set_tile "eb_layer" "BOQ-TABLES")
  (set_tile "eb_csv"   "Dim_Report")
  (set_tile "eb_htitle" "جدول حصر الابعاد")
  (set_tile "eb_hdim"   "البعد")
  (set_tile "eb_hqty"   "التكرار")
  (set_tile "eb_htot"   "الاجمالي")
  (set_tile "eb_hgrand" "الاجمالي الكلي")
  (set_tile "ck_excel"  "0")
  (set_tile "ck_mark"   "1")
  (set_tile "ck_total"  "1")
  (set_tile "ck_layer"  "1")
  (set_tile "rb_c1" "1")
  (set_tile "eb_color" "1")
)

;; ---------- تنفيذ الحصر وبناء الجدول المتناسق ----------
(defun DTP:run (/ ss ent ename obj num val data sorted-data
                   path csv_f pt tbl row rowTotal total count i detectedH
                   numRows totalRows r baseColW)
  (setq total 0.0  count 0  data nil  detectedH nil)

  (if (= DTP:sel_mode "Manual")
    (progn
      (princ "\nاختر الأبعاد المطلوب حصرها ثم اضغط Enter: ")
      (setq ss (ssget '((0 . "DIMENSION"))))
    )
    (progn
      (princ "\nاختر بعداً لتحديد الطبقة المطلوبة: ")
      (setq ent (car (entsel)))
      (if ent
        (setq ss (ssget "X" (list '(0 . "DIMENSION") (assoc 8 (entget ent)))))
      )
    )
  )

  (if (null ss)
    (progn (princ "\nلم يتم اختيار أي أبعاد.") (princ) (exit))
  )

  (setq count (sslength ss))
  (princ (strcat "\nتم تحديد " (itoa count) " بعد — جارٍ المعالجة..."))

  (repeat (setq i count)
    (setq ename (ssname ss (setq i (1- i))))
    (setq obj (vlax-ename->vla-object ename))
    
    (if (and (or (null DTP:txtH) (zerop DTP:txtH)) (null detectedH))
      (setq detectedH (DTP:get-dim-height ename obj))
    )

    (setq num (vla-get-Measurement obj))
    (setq val (rtos num 2 DTP:prec))
    (if DTP:mark_dim (vla-put-color obj DTP:dim_color))
    (if (assoc val data)
      (setq data (subst (list val (1+ (cadr (assoc val data))))
                        (assoc val data) data))
      (setq data (cons (list val 1) data))
    )
  )

  ;; اعتماد الارتفاع الفعلي
  (if (or (null DTP:txtH) (zerop DTP:txtH))
    (setq DTP:txtH (if detectedH detectedH (getvar "TEXTSIZE")))
  )

  ;; الترتيب
  (if DTP:sort_asc
    (setq sorted-data (vl-sort data '(lambda (a b) (< (atof (car a)) (atof (car b))))))
    (setq sorted-data (vl-sort data '(lambda (a b) (> (atof (car a)) (atof (car b))))))
  )

  ;; التصدير إلى Excel/CSV إذا طلب
  (if DTP:exp_excel
    (progn
      (setq path (getfiled "حفظ تقرير حصر الأبعاد" DTP:csv_name "csv" 1))
      (if path
        (progn
          (setq csv_f (open path "w"))
          (write-line (strcat DTP:h_dim "," DTP:h_qty "," DTP:h_tot) csv_f)
          (foreach item sorted-data
            (write-line
              (strcat (car item) "," (itoa (cadr item)) ","
                      (rtos (* (atof (car item)) (cadr item)) 2 DTP:prec))
              csv_f)
          )
          (close csv_f)
          (startapp "explorer" path)
        )
      )
    )
  )

  ;; إدراج الجدول
  (princ "\nحدد نقطة إدراج الجدول: ")
  (setq pt (getpoint))
  (if (null pt) (progn (princ "\nتم الإلغاء.") (princ) (exit)))

  (setq totalRows (+ (length sorted-data) (if DTP:show_total 3 2)))
  (setq baseColW (* DTP:txtH DTP:colW))

  ;; إنشاء كائن الجدول بارتفاع صف مبدئي متناسب
  (setq tbl
    (vla-addtable
      (vla-get-modelspace (vla-get-activedocument (vlax-get-acad-object)))
      (vlax-3d-point pt)
      totalRows
      3
      (* DTP:txtH 2.0)
      baseColW
    )
  )

  ;; ضبط طبقة الجدول
  (if DTP:make_layer
    (progn
      (if (null (tblsearch "LAYER" DTP:layer_name))
        (vla-add (vla-get-layers (vla-get-activedocument (vlax-get-acad-object)))
                 DTP:layer_name)
      )
      (vla-put-layer tbl DTP:layer_name)
    )
  )

  ;; ضبط هوامش الخلايا هندسياً بحسب حجم الخط
  (vl-catch-all-apply 'vla-put-vertcellmargin (list tbl (* DTP:txtH 0.25)))
  (vl-catch-all-apply 'vla-put-horzcellmargin (list tbl (* DTP:txtH 0.40)))

  ;; نسب أحجام النصوص ومحاذاتها
  (vla-settextheight tbl acTitleRow  (* DTP:txtH 1.35))
  (vla-settextheight tbl acHeaderRow (* DTP:txtH 1.15))
  (vla-settextheight tbl acDataRow   DTP:txtH)

  (vla-setalignment  tbl acTitleRow  acMiddleCenter)
  (vla-setalignment  tbl acHeaderRow acMiddleCenter)
  (vla-setalignment  tbl acDataRow   acMiddleCenter)

  ;; نسب ارتفاع الصفوف
  (vl-catch-all-apply 'vla-setrowheight (list tbl 0 (* DTP:txtH 2.6))) ; صف العنوان
  (vl-catch-all-apply 'vla-setrowheight (list tbl 1 (* DTP:txtH 2.2))) ; صف الترويسة
  (setq r 2)
  (repeat (- totalRows 2)
    (vl-catch-all-apply 'vla-setrowheight (list tbl r (* DTP:txtH 1.95)))
    (setq r (1+ r))
  )

  ;; نسب عرض الأعمدة المتناسقة
  (vl-catch-all-apply 'vla-setcolumnwidth (list tbl 0 (* DTP:txtH (max 8.5 (* DTP:colW 0.95))))) ; البعد
  (vl-catch-all-apply 'vla-setcolumnwidth (list tbl 1 (* DTP:txtH (max 6.5 (* DTP:colW 0.70))))) ; التكرار
  (vl-catch-all-apply 'vla-setcolumnwidth (list tbl 2 (* DTP:txtH (max 9.5 (* DTP:colW 1.05))))) ; الإجمالي

  ;; كتابة النصوص
  (vla-settext tbl 0 0 DTP:h_title)
  (vla-settext tbl 1 0 DTP:h_dim)
  (vla-settext tbl 1 1 DTP:h_qty)
  (vla-settext tbl 1 2 DTP:h_tot)

  (setq row 2  total 0.0)
  (foreach item sorted-data
    (setq rowTotal (* (atof (car item)) (cadr item)))
    (setq total (+ total rowTotal))
    (vla-settext tbl row 0 (car item))
    (vla-settext tbl row 1 (itoa (cadr item)))
    (vla-settext tbl row 2 (rtos rowTotal 2 DTP:prec))
    (setq row (1+ row))
  )

  (if DTP:show_total
    (progn
      (vla-settext tbl row 0 DTP:h_grand)
      (vla-settext tbl row 1 (strcat "العدد: " (itoa count)))
      (vla-settext tbl row 2 (rtos total 2 DTP:prec))
    )
  )

  (vla-update tbl)
  (princ (strcat "\nتم إنشاء الجدول بنجاح — الارتفاع المعتمد: " (rtos DTP:txtH 2 2)
                 " | عدد الأبعاد: " (itoa count)
                 " | الإجمالي: " (rtos total 2 DTP:prec)))
  (princ)
)

;; ============================================================
;;  أوامر التشغيل
;; ============================================================
(defun c:ddt (/ dcl-file dcl-id result)
  (setq dcl-file (strcat (getenv "TEMP") "\\DimTa00d.dcl"))
  (DTP:write-dcl dcl-file)

  (setq dcl-id (load_dialog dcl-file))
  (if (< dcl-id 0)
    (progn (alert "خطأ: تعذر تحميل ملف الواجهة!") (princ) (exit))
  )

  (if (not (new_dialog "DimTableProDlg" dcl-id))
    (progn
      (unload_dialog dcl-id)
      (alert "خطأ: لم يتم العثور على تعريف الحوار!")
      (princ) (exit)
    )
  )

  (DTP:set-defaults)

  (action_tile "btn_reset"  "(DTP:reset)")
  (action_tile "btn_ok"     "(DTP:get-values)(done_dialog 1)")
  (action_tile "btn_cancel" "(done_dialog 0)")

  (setq result (start_dialog))
  (unload_dialog dcl-id)

  (if (= result 1)
    (DTP:run)
    (princ "\nتم الإلغاء.")
  )
  (princ)
)

(defun c:DimTablePro () (c:ddt))

(princ "\n>> تم تحديث الأداة. اكتب الأمر: ddt")
(princ)