;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: AMT
;;; الملف الأصلي: ‏‏AreaTable - نسخة (11).LSP
;;;============================================================================
;;; Area Manager Professional - نظام حصر المساحات المتكامل
;;; الإصدار: 5.1 Professional - Fixed Edition
;;; المطور: م/ عامر
;;; تعديلات:
;;; - ترتيب الترقيم من اليمين لليسار ومن الأعلى للأسفل
;;; - تصغير الأرقام والجدول
;;; - إصلاح القوائم popup_list في DCL
;;; - إصلاح ظهور الإجمالي الكلي في الجدول
;;;============================================================================

(vl-load-com)

(setq *AM:Version* "5.1 Professional - Fixed")
(setq *AM:LastSettings* nil)

;;====================================
;; الأمر الرئيسي
;;====================================
(defun c:AreaManager (/ dcl_id dcl_file result)
  (setq dcl_file (AM-CreateDCLFile))
  (setq dcl_id (load_dialog dcl_file))
  (if (not (new_dialog "AreaManagerPro" dcl_id))
    (progn
      (alert "خطأ في تحميل الواجهة الرسومية!")
      (exit)
    )
  )
  (AM-InitDialog)
  (AM-FillPopupLists)
  (AM-SetupActions)
  (setq result (start_dialog))
  (unload_dialog dcl_id)
  (vl-file-delete dcl_file)
  (AM-ProcessResult result)
  (princ)
)

;;====================================
;; ملف الواجهة DCL
;;====================================
(defun AM-CreateDCLFile (/ f fn)
  (setq f (vl-filename-mktemp "AreaMgr" "" ".dcl"))
  (setq fn (open f "w"))
  (foreach ln (list
    "AreaManagerPro : dialog {"
    "  label = \"نظام حصر المساحات - م/ عامر v5.1\";"
    "  initial_focus = \"btn_process\";"
    "  : column {"
    "    : boxed_column { label = \"معلومات المشروع\";"
    "      : edit_box { key = \"proj_title\"; label = \"عنوان الجدول:\"; edit_width = 45; value = \"جدول حصر المساحات\"; }"
    "      : edit_box { key = \"proj_name\"; label = \"اسم المشروع:\"; edit_width = 45; value = \"\"; }"
    "    }"
    "    : boxed_column { label = \"الاعدادات الاساسية\";"
    "      : row {"
    "        : edit_box { key = \"prec_val\"; label = \"الدقة:\"; edit_width = 5; value = \"2\"; }"
    "        : edit_box { key = \"scale_val\"; label = \"المعامل:\"; edit_width = 8; value = \"1.0\"; }"
    "        : popup_list { key = \"unit_val\"; label = \"الوحدة:\"; width = 18; }"
    "      }"
    "      : row {"
    "        : toggle { key = \"auto_size\"; label = \"حجم تلقائي حسب الرسم\"; value = \"1\"; }"
    "        : edit_box { key = \"txt_height\"; label = \"ارتفاع النص:\"; edit_width = 8; value = \"1.8\"; }"
    "      }"
    "    }"
    "    : boxed_column { label = \"نوع العناصر\";"
    "      : popup_list { key = \"sel_type\"; label = \"نوع الكيان:\"; width = 32; }"
    "      : row {"
    "        : toggle { key = \"sel_closed\"; label = \"المغلقة فقط\"; value = \"1\"; }"
    "        : toggle { key = \"sel_ignore_zero\"; label = \"تجاهل الصفرية\"; value = \"1\"; }"
    "      }"
    "    }"
    "    : boxed_column { label = \"خيارات التجميع\";"
    "      : toggle { key = \"grp_enabled\"; label = \"تفعيل التجميع\"; value = \"1\"; }"
    "      : row {"
    "        : toggle { key = \"grp_by_area\"; label = \"حسب المساحة\"; value = \"1\"; }"
    "        : toggle { key = \"grp_by_layer\"; label = \"حسب الطبقة\"; value = \"0\"; }"
    "      }"
    "      : edit_box { key = \"grp_tolerance\"; label = \"نسبة التسامح (%):\"; edit_width = 10; value = \"0.01\"; }"
    "    }"
    "    : boxed_column { label = \"الفرز\";"
    "      : popup_list { key = \"sort_type\"; label = \"طريقة الفرز:\"; width = 24; }"
    "    }"
    "    : boxed_column { label = \"ابعاد الجدول (يدوي)\";"
    "      : row {"
    "        : edit_box { key = \"tbl_row_height\"; label = \"ارتفاع الصف:\"; edit_width = 8; value = \"2.2\"; }"
    "        : edit_box { key = \"tbl_col_width\"; label = \"عرض العمود:\"; edit_width = 8; value = \"18.0\"; }"
    "      }"
    "    }"
    "    : boxed_column { label = \"محتوى الاعمدة\";"
    "      : row {"
    "        : toggle { key = \"col_num\"; label = \"م\"; value = \"1\"; }"
    "        : toggle { key = \"col_area\"; label = \"المساحة\"; value = \"1\"; }"
    "        : toggle { key = \"col_layer\"; label = \"الطبقة\"; value = \"1\"; }"
    "      }"
    "      : row {"
    "        : toggle { key = \"col_count\"; label = \"العدد\"; value = \"1\"; }"
    "        : toggle { key = \"col_percent\"; label = \"النسبة%\"; value = \"1\"; }"
    "        : toggle { key = \"col_subtotal\"; label = \"الاجمالي الفرعي\"; value = \"1\"; }"
    "      }"
    "    }"
    "    : boxed_column { label = \"الترقيم على الرسم\";"
    "      : toggle { key = \"num_on_drawing\"; label = \"كتابة رقم العنصر وسط المساحة\"; value = \"1\"; }"
    "      : row {"
    "        : edit_box { key = \"num_layer\"; label = \"طبقة الترقيم:\"; edit_width = 20; value = \"AREA_NUMBERS\"; }"
    "        : toggle { key = \"num_auto_size\"; label = \"حجم تلقائي\"; value = \"1\"; }"
    "      }"
    "      : edit_box { key = \"num_txt_height\"; label = \"ارتفاع النص:\"; edit_width = 8; value = \"1.2\"; }"
    "    }"
    "    : boxed_column { label = \"التنسيق\";"
    "      : toggle { key = \"tbl_color_layer\"; label = \"تلوين حسب الطبقة\"; value = \"0\"; }"
    "    }"
    "    : boxed_column { label = \"تصدير\";"
    "      : row {"
    "        : toggle { key = \"exp_csv\"; label = \"CSV\"; value = \"0\"; }"
    "        : toggle { key = \"rep_summary\"; label = \"ملخص احصائي\"; value = \"0\"; }"
    "      }"
    "    }"
    "    spacer;"
    "    : row {"
    "      alignment = centered;"
    "      : button { key = \"btn_process\"; label = \"بدء الحصر والانشاء\"; is_default = true; width = 25; }"
    "      : button { key = \"btn_cancel\"; label = \"الغاء\"; is_cancel = true; width = 10; }"
    "    }"
    "    : text { label = \"تطوير: م/ عامر | Fixed Edition\"; alignment = centered; }"
    "  }"
    "}"
  )
    (write-line ln fn)
  )
  (close fn)
  f
)

;;====================================
;; تعبئة القوائم المنسدلة بشكل صحيح
;;====================================
(defun AM-SetPopupItems (key items /)
  (start_list key)
  (mapcar 'add_list items)
  (end_list)
)

(defun AM-FillPopupLists ()
  (AM-SetPopupItems "unit_val" '("م2" "ف2" "كم2" "هكتار" "دونم"))
  (AM-SetPopupItems "sel_type" '("بولي لاين مغلقة" "بولي لاين مفتوحة" "مناطق" "هاتش" "الكل"))
  (AM-SetPopupItems "sort_type" '("ترتيب الرسم: يمين-يسار ثم أعلى-أسفل" "تصاعدي حسب المساحة" "تنازلي حسب المساحة" "حسب الطبقة"))

  (if *AM:LastSettings*
    (progn
      (if (assoc "unit_val" *AM:LastSettings*) (set_tile "unit_val" (cdr (assoc "unit_val" *AM:LastSettings*))) (set_tile "unit_val" "0"))
      (if (assoc "sel_type" *AM:LastSettings*) (set_tile "sel_type" (cdr (assoc "sel_type" *AM:LastSettings*))) (set_tile "sel_type" "0"))
      (if (assoc "sort_type" *AM:LastSettings*) (set_tile "sort_type" (cdr (assoc "sort_type" *AM:LastSettings*))) (set_tile "sort_type" "0"))
    )
    (progn
      (set_tile "unit_val" "0")
      (set_tile "sel_type" "0")
      (set_tile "sort_type" "0")
    )
  )
)

;;====================================
;; تهيئة وأحداث الحوار
;;====================================
(defun AM-InitDialog ()
  (if *AM:LastSettings*
    (foreach key '("proj_title" "proj_name" "prec_val" "scale_val"
                   "tbl_row_height" "tbl_col_width" "txt_height"
                   "grp_tolerance" "num_layer" "num_txt_height"
                   "auto_size" "sel_closed" "sel_ignore_zero"
                   "grp_enabled" "grp_by_area" "grp_by_layer"
                   "col_num" "col_area" "col_layer" "col_count"
                   "col_percent" "col_subtotal" "tbl_color_layer"
                   "num_on_drawing" "num_auto_size" "exp_csv" "rep_summary")
      (if (assoc key *AM:LastSettings*)
        (set_tile key (cdr (assoc key *AM:LastSettings*)))
      )
    )
  )
)

(defun AM-SetupActions ()
  (action_tile "btn_process" "(AM-SaveSettings)(done_dialog 1)")
  (action_tile "btn_cancel"  "(done_dialog 0)")
)

(defun AM-SaveSettings ()
  (setq *AM:LastSettings*
    (mapcar '(lambda (k) (cons k (get_tile k)))
      '("proj_title" "proj_name" "prec_val" "scale_val" "unit_val"
        "auto_size" "txt_height"
        "sel_type" "sel_closed" "sel_ignore_zero"
        "grp_enabled" "grp_by_area" "grp_by_layer" "grp_tolerance"
        "sort_type"
        "tbl_row_height" "tbl_col_width"
        "col_num" "col_area" "col_layer" "col_count" "col_percent" "col_subtotal"
        "tbl_color_layer"
        "num_on_drawing" "num_layer" "num_auto_size" "num_txt_height"
        "exp_csv" "rep_summary"
      )
    )
  )
)

(defun AM-Get (k) (cdr (assoc k *AM:LastSettings*)))

;;====================================
;; معالجة النتيجة
;;====================================
(defun AM-ProcessResult (result)
  (cond
    ((= result 1) (AM-Start))
    (T (princ "\nتم الإلغاء."))
  )
)

;;====================================
;; حساب الحجم التلقائي - مصغر
;;====================================
(defun AM-AutoSize (/ doc mspace obj bb_min bb_max ax1 ay1 ax2 ay2 first_p w h sz res)
  (setq res
    (vl-catch-all-apply
      '(lambda ()
         (setq doc (vla-get-activedocument (vlax-get-acad-object)))
         (setq mspace (vla-get-modelspace doc))
         (setq first_p T)
         (vlax-for obj mspace
           (vl-catch-all-apply
             '(lambda ()
                (vla-getboundingbox obj 'bb_min 'bb_max)
                (setq bb_min (vlax-safearray->list bb_min))
                (setq bb_max (vlax-safearray->list bb_max))
                (if first_p
                  (progn
                    (setq ax1 (car bb_min) ay1 (cadr bb_min))
                    (setq ax2 (car bb_max) ay2 (cadr bb_max))
                    (setq first_p nil)
                  )
                  (progn
                    (if (< (car bb_min) ax1) (setq ax1 (car bb_min)))
                    (if (< (cadr bb_min) ay1) (setq ay1 (cadr bb_min)))
                    (if (> (car bb_max) ax2) (setq ax2 (car bb_max)))
                    (if (> (cadr bb_max) ay2) (setq ay2 (cadr bb_max)))
                  )
                )
              )
           )
         )
         (if (not first_p)
           (progn
             (setq w (abs (- ax2 ax1)) h (abs (- ay2 ay1)))
             (setq sz (* (max w h) 0.0075))
             (max 0.8 (min 6.0 sz))
           )
           1.2
         )
       )
    )
  )
  (if (or (vl-catch-all-error-p res) (not (numberp res))) 1.2 res)
)

;;====================================
;; بدء المعالجة
;;====================================
(defun AM-Start (/ ss filter_list obj_type)
  (setq obj_type (AM-Get "sel_type"))
  (setq filter_list
    (cond
      ((= obj_type "0") '((0 . "LWPOLYLINE,POLYLINE")))
      ((= obj_type "1") '((0 . "LWPOLYLINE,POLYLINE")))
      ((= obj_type "2") '((0 . "REGION")))
      ((= obj_type "3") '((0 . "HATCH")))
      (T '((0 . "LWPOLYLINE,POLYLINE,REGION,HATCH")))
    )
  )
  (if (and (= obj_type "0") (= (AM-Get "sel_closed") "1"))
    (setq filter_list (append filter_list '((-4 . "<AND") (70 . 1) (-4 . "AND>"))))
  )
  (princ "\nاختر العناصر المراد حصرها (Enter للانتهاء)...")
  (setq ss (ssget filter_list))
  (if ss
    (AM-ProcessSS ss)
    (princ "\nلم يتم اختيار أي عناصر!")
  )
)

;;====================================
;; معالجة الاختيار
;;====================================
(defun AM-ProcessSS (ss / i ent obj data item lst total_area total_count grouped sorted)
  (setq lst '() total_area 0.0 total_count 0 i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i)
          obj (vlax-ename->vla-object ent)
          item (AM-ExtractData obj ent))
    (if item
      (progn
        (setq lst (cons item lst))
        (setq total_area (+ total_area (cdr (assoc 'area item))))
        (setq total_count (1+ total_count))
      )
    )
    (setq i (1+ i))
  )
  (if (> (length lst) 0)
    (progn
      (princ (strcat "\nتم العثور على " (itoa total_count) " عنصر"))
      (princ (strcat "\nاجمالي المساحة: " (rtos total_area 2 (atoi (AM-Get "prec_val"))) " " (AM-UnitStr)))
      (setq lst (reverse lst))
      (setq grouped  (AM-Group lst))
      (setq sorted   (AM-Sort grouped))
      (if (= (AM-Get "num_on_drawing") "1")
        (AM-NumberOnDrawing sorted)
      )
      (if (= (AM-Get "exp_csv") "1")
        (AM-ExportCSV sorted total_area)
      )
      (if (= (AM-Get "rep_summary") "1")
        (AM-Summary sorted total_area total_count)
      )
      (AM-CreateTable sorted total_area total_count)
    )
    (princ "\nلا توجد بيانات صالحة!")
  )
)

;;====================================
;; استخراج بيانات الكيان
;;====================================
(defun AM-ExtractData (obj ent / area layer color handle cent)
  (setq area (vl-catch-all-apply 'vlax-get-property (list obj 'Area)))
  (if (and (not (vl-catch-all-error-p area)) (numberp area))
    (progn
      (setq area (* area (atof (AM-Get "scale_val"))))
      (if (and (= (AM-Get "sel_ignore_zero") "1") (<= area 0.0))
        nil
        (progn
          (setq layer  (AM-SafeGet obj 'vla-get-layer "0"))
          (setq color  (AM-SafeGetN obj 'vla-get-color 256))
          (setq handle (AM-SafeGet obj 'vla-get-handle ""))
          (setq cent   (AM-GetCenter obj))
          (list
            (cons 'area area)
            (cons 'layer layer)
            (cons 'color color)
            (cons 'handle handle)
            (cons 'centroid cent)
            (cons 'entity ent)
          )
        )
      )
    )
    nil
  )
)

(defun AM-SafeGet (obj fn default / r)
  (setq r (vl-catch-all-apply fn (list obj)))
  (if (vl-catch-all-error-p r) default r)
)

(defun AM-SafeGetN (obj fn default / r)
  (setq r (vl-catch-all-apply fn (list obj)))
  (if (or (vl-catch-all-error-p r) (not (numberp r))) default r)
)

;;====================================
;; حساب مركز الكيان
;;====================================
(defun AM-GetCenter (obj / bb_min bb_max r)
  (setq r
    (vl-catch-all-apply
      '(lambda ()
         (vla-getboundingbox obj 'bb_min 'bb_max)
         (setq bb_min (vlax-safearray->list bb_min))
         (setq bb_max (vlax-safearray->list bb_max))
         (list
           (/ (+ (car bb_min) (car bb_max)) 2.0)
           (/ (+ (cadr bb_min) (cadr bb_max)) 2.0)
           0.0
         )
       )
    )
  )
  (if (vl-catch-all-error-p r) nil r)
)

;;====================================
;; التجميع
;;====================================
(defun AM-Group (data / result key item existing tol prec)
  (if (= (AM-Get "grp_enabled") "1")
    (progn
      (setq result '())
      (setq tol (atof (AM-Get "grp_tolerance")))
      (if (<= tol 0.0) (setq tol 0.01))
      (setq prec (atoi (AM-Get "prec_val")))
      (foreach item data
        (setq key (AM-BuildKey item prec))
        (setq existing (AM-FindGroup key result))
        (if existing
          (setq result (AM-UpdateGroup existing item result prec))
          (setq result (cons (AM-NewGroup key item prec) result))
        )
      )
      (reverse result)
    )
    (mapcar
      '(lambda (x / prec)
         (setq prec (atoi (AM-Get "prec_val")))
         (list
           (rtos (cdr (assoc 'area x)) 2 prec)
           (rtos (cdr (assoc 'area x)) 2 prec)
           (cdr (assoc 'area x))
           1
           (cdr (assoc 'layer x))
           (list x)
         )
       )
      data
    )
  )
)

(defun AM-BuildKey (item prec / av key)
  (setq av (cdr (assoc 'area item)))
  (setq key (rtos av 2 prec))
  (if (= (AM-Get "grp_by_layer") "1")
    (setq key (strcat key "|" (cdr (assoc 'layer item))))
  )
  key
)

(defun AM-FindGroup (key lst)
  (cond
    ((null lst) nil)
    ((equal (car (car lst)) key) (car lst))
    (T (AM-FindGroup key (cdr lst)))
  )
)

(defun AM-NewGroup (key item prec)
  (list key
    (rtos (cdr (assoc 'area item)) 2 prec)
    (cdr (assoc 'area item))
    1
    (cdr (assoc 'layer item))
    (list item)
  )
)

(defun AM-UpdateGroup (existing item result prec / na nc ne)
  (setq na (+ (caddr existing) (cdr (assoc 'area item))))
  (setq nc (1+ (cadddr existing)))
  (setq ne (cons item (nth 5 existing)))
  (subst
    (list (car existing) (rtos na 2 prec) na nc (nth 4 existing) ne)
    existing result
  )
)

;;====================================
;; فرز المجموعات حسب موقع الرسم: من الأعلى للأسفل ثم من اليمين لليسار
;;====================================
(defun AM-GroupRefPoint (grp / ents p x y n)
  (setq ents (nth 5 grp))
  (setq x 0.0 y 0.0 n 0)
  (foreach e ents
    (setq p (cdr (assoc 'centroid e)))
    (if (and p (listp p) (>= (length p) 2))
      (progn
        (setq x (+ x (car p)))
        (setq y (+ y (cadr p)))
        (setq n (1+ n))
      )
    )
  )
  (if (> n 0)
    (list (/ x n) (/ y n) 0.0)
    '(0.0 0.0 0.0)
  )
)

(defun AM-Sort (data / mode)
  (setq mode (AM-Get "sort_type"))
  (cond
    ((= mode "1")
      (vl-sort data '(lambda (a b) (< (caddr a) (caddr b))))
    )
    ((= mode "2")
      (vl-sort data '(lambda (a b) (> (caddr a) (caddr b))))
    )
    ((= mode "3")
      (vl-sort data '(lambda (a b)
        (if (= (nth 4 a) (nth 4 b))
          (< (caddr a) (caddr b))
          (< (nth 4 a) (nth 4 b))
        )
      ))
    )
    (T
      (vl-sort data
        '(lambda (a b / pa pb ya yb xa xb band)
           (setq pa (AM-GroupRefPoint a))
           (setq pb (AM-GroupRefPoint b))
           (setq ya (cadr pa) yb (cadr pb) xa (car pa) xb (car pb))
           (setq band 1.0)
           (if (> (abs (- ya yb)) band)
             (> ya yb)
             (> xa xb)
           )
         )
      )
    )
  )
)

;;====================================
;; ترقيم العناصر على الرسم
;;====================================
(defun AM-NumberOnDrawing (sorted_groups / doc mspace lyr_name txt_h idx grp ent_data cent txt_obj r)
  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq mspace (vla-get-modelspace doc))
  (setq lyr_name (AM-Get "num_layer"))
  (if (or (not lyr_name) (= lyr_name "")) (setq lyr_name "AREA_NUMBERS"))

  (AM-MakeLayer lyr_name 1 doc)

  (if (= (AM-Get "num_auto_size") "1")
    (setq txt_h (max 0.8 (* (AM-AutoSize) 0.60)))
    (setq txt_h (atof (AM-Get "num_txt_height")))
  )
  (if (<= txt_h 0) (setq txt_h 1.0))

  (setq idx 1)
  (foreach grp sorted_groups
    (foreach ent_data (nth 5 grp)
      (setq cent (cdr (assoc 'centroid ent_data)))
      (if (and cent (listp cent) (>= (length cent) 2))
        (progn
          (if (= (length cent) 2) (setq cent (append cent '(0.0))))
          (setq r
            (vl-catch-all-apply
              '(lambda ()
                 (setq txt_obj (vla-addtext mspace (itoa idx) (vlax-3d-point cent) txt_h))
                 (vla-put-layer txt_obj lyr_name)
                 (vla-put-color txt_obj 1)
                 (vla-put-alignment txt_obj acAlignmentMiddleCenter)
                 (vla-put-textAlignmentPoint txt_obj (vlax-3d-point cent))
                 (vla-update txt_obj)
               )
            )
          )
          (if (vl-catch-all-error-p r)
            (princ (strcat "\nتحذير: فشل كتابة رقم " (itoa idx)))
          )
        )
      )
    )
    (setq idx (1+ idx))
  )
  (princ (strcat "\nتم كتابة " (itoa (1- idx)) " رقم على الرسم في الطبقة: " lyr_name))
)

;;====================================
;; إنشاء طبقة بأمان
;;====================================
(defun AM-MakeLayer (lyr_name clr doc / layers lyr r)
  (setq layers (vla-get-layers doc))
  (setq r (vl-catch-all-apply 'vla-item (list layers lyr_name)))
  (if (vl-catch-all-error-p r)
    (progn
      (setq lyr (vl-catch-all-apply 'vla-add (list layers lyr_name)))
      (if (not (vl-catch-all-error-p lyr))
        (vl-catch-all-apply 'vla-put-color (list lyr clr))
      )
    )
  )
)

;;====================================
;; إنشاء الجدول
;;====================================
(defun AM-CreateTable (data total_area total_count /
                        pt doc mspace tbl nc nr
                        row col cnt unit prec txt_h row_h col_w
                        cur_area cur_count cur_layer sub_total disp_area
                        col_idx total_label_end)

  (setq pt (getpoint "\nاختر نقطة ادراج الجدول: "))
  (if (not pt) (progn (princ "\nإلغاء.") (exit)))

  (setq doc    (vla-get-activedocument (vlax-get-acad-object)))
  (setq mspace (vla-get-modelspace doc))
  (setq unit   (AM-UnitStr))
  (setq prec   (atoi (AM-Get "prec_val")))

  (if (= (AM-Get "auto_size") "1")
    (progn
      (setq txt_h (max 0.8 (* (AM-AutoSize) 0.55)))
      (setq row_h (max 1.4 (* txt_h 1.35)))
      (setq col_w (max 8.0 (* txt_h 6.0)))
    )
    (progn
      (setq txt_h (atof (AM-Get "txt_height")))
      (setq row_h (atof (AM-Get "tbl_row_height")))
      (setq col_w (atof (AM-Get "tbl_col_width")))
    )
  )
  (if (<= txt_h 0.4) (setq txt_h 0.9))
  (if (<= row_h 0.5) (setq row_h 1.6))
  (if (<= col_w 5.0) (setq col_w 10.0))

  (setq nc 0)
  (if (= (AM-Get "col_num")      "1") (setq nc (1+ nc)))
  (if (= (AM-Get "col_area")     "1") (setq nc (1+ nc)))
  (if (= (AM-Get "col_layer")    "1") (setq nc (1+ nc)))
  (if (= (AM-Get "col_count")    "1") (setq nc (1+ nc)))
  (if (= (AM-Get "col_percent")  "1") (setq nc (1+ nc)))
  (if (= (AM-Get "col_subtotal") "1") (setq nc (1+ nc)))
  (if (< nc 1) (setq nc 1))

  (setq nr (+ (length data) 3))
  (setq tbl (vla-addtable mspace (vlax-3d-point pt) nr nc row_h col_w))

  (if (> nc 1) (vla-mergecells tbl 0 0 0 (1- nc)))
  (vla-settext tbl 0 0 (AM-Get "proj_title"))
  (vla-setcelltextheight tbl 0 0 txt_h)

  (setq col 0)
  (if (= (AM-Get "col_num") "1")
    (progn (vla-settext tbl 1 col "م") (setq col (1+ col))))
  (if (= (AM-Get "col_area") "1")
    (progn (vla-settext tbl 1 col (strcat "المساحة (" unit ")")) (setq col (1+ col))))
  (if (= (AM-Get "col_layer") "1")
    (progn (vla-settext tbl 1 col "الطبقة") (setq col (1+ col))))
  (if (= (AM-Get "col_count") "1")
    (progn (vla-settext tbl 1 col "العدد") (setq col (1+ col))))
  (if (= (AM-Get "col_percent") "1")
    (progn (vla-settext tbl 1 col "النسبة %") (setq col (1+ col))))
  (if (= (AM-Get "col_subtotal") "1")
    (progn (vla-settext tbl 1 col (strcat "الاجمالي الفرعي (" unit ")")) (setq col (1+ col))))

  (setq row 2 cnt 1)
  (foreach item data
    (setq cur_area   (caddr item))
    (setq cur_count  (cadddr item))
    (setq cur_layer  (nth 4 item))
    (setq sub_total  cur_area)
    (if (> cur_count 1)
      (setq disp_area (/ cur_area (float cur_count)))
      (setq disp_area cur_area)
    )

    (setq col 0)
    (if (= (AM-Get "col_num") "1")
      (progn (vla-settext tbl row col (itoa cnt)) (setq col (1+ col))))
    (if (= (AM-Get "col_area") "1")
      (progn (vla-settext tbl row col (rtos disp_area 2 prec)) (setq col (1+ col))))
    (if (= (AM-Get "col_layer") "1")
      (progn
        (vla-settext tbl row col cur_layer)
        (if (= (AM-Get "tbl_color_layer") "1")
          (AM-ColorCell tbl row col cur_layer)
        )
        (setq col (1+ col))
      )
    )
    (if (= (AM-Get "col_count") "1")
      (progn (vla-settext tbl row col (itoa cur_count)) (setq col (1+ col))))
    (if (= (AM-Get "col_percent") "1")
      (progn
        (vla-settext tbl row col
          (if (> total_area 0.0)
            (strcat (rtos (* 100.0 (/ sub_total total_area)) 2 1) "%")
            "0%"
          )
        )
        (setq col (1+ col))
      )
    )
    (if (= (AM-Get "col_subtotal") "1")
      (progn (vla-settext tbl row col (rtos sub_total 2 prec)) (setq col (1+ col))))

    (setq row (1+ row) cnt (1+ cnt))
  )

  ;; إصلاح صف الإجمالي: دمج أولاً ثم كتابة النص
  (setq total_label_end 0)
  (if (= (AM-Get "col_num") "1")   (setq total_label_end (1+ total_label_end)))
  (if (= (AM-Get "col_area") "1")  (setq total_label_end (1+ total_label_end)))
  (if (= (AM-Get "col_layer") "1") (setq total_label_end (1+ total_label_end)))
  (setq total_label_end (1- total_label_end))
  (if (< total_label_end 0) (setq total_label_end 0))

  (if (> total_label_end 0)
    (vla-mergecells tbl row 0 row total_label_end)
  )
  (vla-settext tbl row 0 "الاجمالي الكلي")
  (vla-setcelltextheight tbl row 0 txt_h)

  (setq col_idx 0)
  (if (= (AM-Get "col_num") "1")
    (progn
      (if (> col_idx total_label_end)
        (vla-settext tbl row col_idx "")
      )
      (setq col_idx (1+ col_idx))
    )
  )
  (if (= (AM-Get "col_area") "1")
    (progn
      (if (> col_idx total_label_end)
        (vla-settext tbl row col_idx "")
      )
      (setq col_idx (1+ col_idx))
    )
  )
  (if (= (AM-Get "col_layer") "1")
    (progn
      (if (> col_idx total_label_end)
        (vla-settext tbl row col_idx "")
      )
      (setq col_idx (1+ col_idx))
    )
  )
  (if (= (AM-Get "col_count") "1")
    (progn
      (vla-settext tbl row col_idx (itoa total_count))
      (setq col_idx (1+ col_idx))
    )
  )
  (if (= (AM-Get "col_percent") "1")
    (progn
      (vla-settext tbl row col_idx "100%")
      (setq col_idx (1+ col_idx))
    )
  )
  (if (= (AM-Get "col_subtotal") "1")
    (progn
      (vla-settext tbl row col_idx (rtos total_area 2 prec))
      (setq col_idx (1+ col_idx))
    )
  )

  (vl-catch-all-apply 'vla-setalignment (list tbl acdatarow  acmiddlecenter))
  (vl-catch-all-apply 'vla-setalignment (list tbl achdrrow   acmiddlecenter))
  (vl-catch-all-apply 'vla-setalignment (list tbl actitlerow acmiddlecenter))

  (princ (strcat "\nتم انشاء الجدول! (" (itoa (length data))
    " مجموعة - " (itoa total_count) " عنصر)"))
  tbl
)

;;====================================
;; تلوين خلية
;;====================================
(defun AM-ColorCell (tbl row col lyr_name / le lo clr)
  (setq le (tblobjname "layer" lyr_name))
  (if le
    (progn
      (setq lo  (vlax-ename->vla-object le))
      (setq clr (vl-catch-all-apply 'vla-get-truecolor (list lo)))
      (if (not (vl-catch-all-error-p clr))
        (vl-catch-all-apply 'vla-setcellcontentcolor (list tbl row col clr))
      )
    )
  )
)

;;====================================
;; وحدة القياس
;;====================================
(defun AM-UnitStr ()
  (nth (atoi (AM-Get "unit_val")) '("م2" "ف2" "كم2" "هكتار" "دونم"))
)

;;====================================
;; تصدير CSV
;;====================================
(defun AM-ExportCSV (data total_area / fp fn unit prec cnt item sub)
  (setq fp (getfiled "حفظ CSV" "area_report" "csv" 1))
  (if fp
    (progn
      (setq fn (open fp "w") unit (AM-UnitStr) prec (atoi (AM-Get "prec_val")) cnt 1)
      (write-line "No.,Unit_Area,Layer,Count,Percentage,Subtotal,Unit" fn)
      (foreach item data
        (setq sub (caddr item))
        (write-line (strcat
          (itoa cnt) ","
          (cadr item) ","
          (nth 4 item) ","
          (itoa (cadddr item)) ","
          (if (> total_area 0.0) (strcat (rtos (* 100.0 (/ sub total_area)) 2 2) "%") "0%") ","
          (rtos sub 2 prec) ","
          unit
        ) fn)
        (setq cnt (1+ cnt))
      )
      (close fn)
      (princ (strcat "\nCSV: " fp))
    )
  )
)

;;====================================
;; ملخص إحصائي
;;====================================
(defun AM-Summary (data total_area total_count / mn mx av)
  (setq mn (apply 'min (mapcar 'caddr data)))
  (setq mx (apply 'max (mapcar 'caddr data)))
  (setq av (if (> total_count 0) (/ total_area total_count) 0.0))
  (alert (strcat
    "=== ملخص احصائي ===\n"
    "المجموعات: " (itoa (length data)) "\n"
    "اجمالي العناصر: " (itoa total_count) "\n"
    "اجمالي المساحة: " (rtos total_area 2 2) " " (AM-UnitStr) "\n"
    "اصغر: " (rtos mn 2 2) "  |  اكبر: " (rtos mx 2 2) "\n"
    "المتوسط: " (rtos av 2 2)
  ))
)

;;====================================
;; أوامر مختصرة
;;====================================
(defun c:AM ()      (c:AreaManager))
(defun c:Areamgr () (c:AreaManager))

(princ (strcat "\nنظام حصر المساحات " *AM:Version* " جاهز!"))
(princ "\nالاوامر: AreaManager | AM | Areamgr")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:AMT () (c:AreaManager))
