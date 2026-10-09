;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: B90
;;; الملف الأصلي: BLK90.lsp
(vl-load-com)

;;; ================================================================
;;; 1. دالة حساب نسبة التشابه الإسمي (Levenshtein Distance)
;;; ================================================================
(defun get-levenshtein-dist (s1 s2 / len1 len2 i j c1 c2 cost row prev-row)
  (setq s1 (strcase (vl-string-trim " " s1))
        s2 (strcase (vl-string-trim " " s2))
        len1 (strlen s1)
        len2 (strlen s2))
  (cond
    ((= len1 0) len2)
    ((= len2 0) len1)
    (t
     (setq prev-row nil j 0)
     (while (<= j len2)
       (setq prev-row (cons j prev-row)
             j (1+ j)))
     (setq prev-row (reverse prev-row)
           i 1)
     (while (<= i len1)
       (setq c1 (substr s1 i 1)
             row (list i)
             j 1)
       (while (<= j len2)
         (setq c2 (substr s2 j 1)
               cost (if (= c1 c2) 0 1)
               row (cons (min (1+ (car row))
                              (1+ (nth j prev-row))
                              (+ (nth (1- j) prev-row) cost))
                         row)
               j (1+ j)))
       (setq prev-row (reverse row)
             i (1+ i)))
     (last prev-row))))

(defun get-str-similarity (s1 s2 / maxl)
  (setq maxl (max (strlen s1) (strlen s2)))
  (if (= maxl 0)
    1.0
    (- 1.0 (/ (float (get-levenshtein-dist s1 s2)) (float maxl)))))

;;; ================================================================
;;; 2. التدقيق الهندسي الداخلي للبلوك (تصحيح فرز العناصر بـ <)
;;; ================================================================
(defun get-blk-geo-sig (bname / blk-ent ent-name ed etype types-count total-ents
                               min-x min-y max-x max-y p10 p11 r)
  (setq types-count nil total-ents 0
        min-x 1e99 min-y 1e99 max-x -1e99 max-y -1e99)
  
  (if (setq blk-ent (tblsearch "BLOCK" bname))
    (progn
      (setq ent-name (cdr (assoc -2 blk-ent)))
      (while ent-name
        (setq ed (entget ent-name)
              etype (cdr (assoc 0 ed)))
        (if (not (member etype '("ENDBLK" "ATTDEF")))
          (progn
            (setq total-ents (1+ total-ents))
            (if (assoc etype types-count)
              (setq types-count (subst (cons etype (1+ (cdr (assoc etype types-count))))
                                       (assoc etype types-count)
                                       types-count))
              (setq types-count (cons (cons etype 1) types-count)))
            
            ;; حساب الحدود الهندسية
            (cond
              ((= etype "LINE")
               (setq p10 (cdr (assoc 10 ed))
                     p11 (cdr (assoc 11 ed))
                     min-x (min min-x (car p10) (car p11))
                     min-y (min min-y (cadr p10) (cadr p11))
                     max-x (max max-x (car p10) (car p11))
                     max-y (max max-y (cadr p10) (cadr p11))))
              ((member etype '("CIRCLE" "ARC"))
               (setq p10 (cdr (assoc 10 ed))
                     r   (cdr (assoc 40 ed)))
               (setq min-x (min min-x (- (car p10) r))
                     min-y (min min-y (- (cadr p10) r))
                     max-x (max max-x (+ (car p10) r))
                     max-y (max max-y (+ (cadr p10) r))))
              ((= etype "LWPOLYLINE")
               (foreach pt ed
                 (if (= (car pt) 10)
                   (setq min-x (min min-x (cadr pt))
                         min-y (min min-y (caddr pt))
                         max-x (max max-x (cadr pt))
                         max-y (max max-y (caddr pt)))))))
          ))
        (setq ent-name (entnext ent-name)))
      
      (if (= total-ents 0)
        (setq min-x 0.0 min-y 0.0 max-x 0.0 max-y 0.0))
      
      ;; الفرز القياسي المتوافق مع AutoLISP
      (setq types-count (vl-sort types-count '(lambda (a b) (< (car a) (car b)))))
      
      (list total-ents
            types-count
            (abs (- max-x min-x))
            (abs (- max-y min-y))
            (list min-x min-y max-x max-y))
    )))

(defun compare-blk-geo (sig1 sig2 / cnt1 cnt2 typ1 typ2 dx1 dx2 dy1 dy2)
  (if (and sig1 sig2)
    (progn
      (setq cnt1 (nth 0 sig1) cnt2 (nth 0 sig2)
            typ1 (nth 1 sig1) typ2 (nth 1 sig2)
            dx1  (nth 2 sig1) dx2  (nth 2 sig2)
            dy1  (nth 3 sig1) dy2  (nth 3 sig2))
      (cond
        ((and (= cnt1 cnt2)
              (equal typ1 typ2)
              (equal dx1 dx2 0.05)
              (equal dy1 dy2 0.05))
         (list "تطابق هندسي تام (100%)" "MATCH"))
        ((and (= cnt1 cnt2) (equal typ1 typ2))
         (list "نفس العناصر مع اختلاف نسبي في المقاس" "DIFF_SIZE"))
        ((= cnt1 cnt2)
         (list "نفس عدد العناصر باختلاف الأنواع" "DIFF_TYPES"))
        (t
         (list (strcat "اختلاف المكونات (" (itoa cnt2) " مقابل " (itoa cnt1) " عنصر)") "MISMATCH"))))
    (list "تعذر قراءة المكونات" "UNKNOWN")))

;;; ================================================================
;;; 3. محرك رسم المعاينة المتجهة (Vector Preview Renderer)
;;; ================================================================
(defun draw-block-preview (bname tile-key / blk-ent ent-name ed etype
                                 sig bounds min-x min-y max-x max-y
                                 box-w box-h tw th sc off-x off-y
                                 p10 p11 pts p1 p2 cx cy r segs i-ang d-ang a1 a2)
  (setq tw (dimx_tile tile-key)
        th (dimy_tile tile-key))
  
  (start_image tile-key)
  (fill_image 0 0 tw th 0) ; خلفية داكنة

  (setq sig (get-blk-geo-sig bname))
  (if (and sig (> (nth 0 sig) 0))
    (progn
      (setq bounds (nth 4 sig)
            min-x (nth 0 bounds) min-y (nth 1 bounds)
            max-x (nth 2 bounds) max-y (nth 3 bounds)
            box-w (max (- max-x min-x) 0.001)
            box-h (max (- max-y min-y) 0.001))

      (setq sc (min (/ (- tw 24.0) box-w) (/ (- th 24.0) box-h)))
      (setq off-x (+ (/ (- tw (* box-w sc)) 2.0) (- (* min-x sc))))
      (setq off-y (+ (/ (- th (* box-h sc)) 2.0) (* max-y sc)))

      (setq blk-ent (tblsearch "BLOCK" bname)
            ent-name (cdr (assoc -2 blk-ent)))
      (while ent-name
        (setq ed (entget ent-name)
              etype (cdr (assoc 0 ed)))
        (cond
          ((= etype "LINE")
           (setq p10 (cdr (assoc 10 ed))
                 p11 (cdr (assoc 11 ed)))
           (vector_image (fix (+ (* (car p10) sc) off-x))
                         (fix (- off-y (* (cadr p10) sc)))
                         (fix (+ (* (car p11) sc) off-x))
                         (fix (- off-y (* (cadr p11) sc))) 3)) ; لون أخضر
          
          ((= etype "LWPOLYLINE")
           (setq pts nil)
           (foreach it ed
             (if (= (car it) 10) (setq pts (cons (cdr it) pts))))
           (setq pts (reverse pts))
           (if (> (length pts) 1)
             (progn
               (setq p1 (car pts))
               (foreach p2 (cdr pts)
                 (vector_image (fix (+ (* (car p1) sc) off-x))
                               (fix (- off-y (* (cadr p1) sc)))
                               (fix (+ (* (car p2) sc) off-x))
                               (fix (- off-y (* (cadr p2) sc))) 2) ; لون أصفر
                 (setq p1 p2))
               (if (= (logand (cdr (assoc 70 ed)) 1) 1)
                 (vector_image (fix (+ (* (car p1) sc) off-x))
                               (fix (- off-y (* (cadr p1) sc)))
                               (fix (+ (* (car (car pts)) sc) off-x))
                               (fix (- off-y (* (cadr (car pts)) sc))) 2)))))
          
          ((member etype '("CIRCLE" "ARC"))
           (setq p10 (cdr (assoc 10 ed))
                 r   (cdr (assoc 40 ed))
                 cx  (car p10) cy (cadr p10)
                 segs 16 i-ang 0 d-ang (/ (* 2.0 pi) segs))
           (repeat segs
             (setq a1 (* i-ang d-ang)
                   a2 (* (1+ i-ang) d-ang))
             (vector_image (fix (+ (* (+ cx (* r (cos a1))) sc) off-x))
                           (fix (- off-y (* (+ cy (* r (sin a1))) sc)))
                           (fix (+ (* (+ cx (* r (cos a2))) sc) off-x))
                           (fix (- off-y (* (+ cy (* r (sin a2))) sc))) 4) ; سماوي
             (setq i-ang (1+ i-ang)))))
        (setq ent-name (entnext ent-name)))
      
      ;; إطار تحديد
      (vector_image 1 1 (1- tw) 1 8)
      (vector_image (1- tw) 1 (1- tw) (1- th) 8)
      (vector_image (1- tw) (1- th) 1 (1- th) 8)
      (vector_image 1 (1- th) 1 1 8))
    (progn
      (vector_image 0 0 tw th 1)
      (vector_image 0 th tw 0 1)))
  (end_image))

;;; ================================================================
;;; 4. جلب الاسم الفعلي للبلوك (Dynamic Block Support)
;;; ================================================================
(defun get-blk-real-name (ent / obj)
  (setq obj (vlax-ename->vla-object ent))
  (if (vlax-property-available-p obj 'EffectiveName)
    (vla-get-EffectiveName obj)
    (vla-get-Name obj)))

;;; ================================================================
;;; 5. بناء واجهة DCL
;;; ================================================================
(defun build-advanced-dcl (/ path f)
  (setq path (vl-filename-mktemp "blk_ui_pro.dcl"))
  (setq f (open path "w"))
  
  ;; شاشة الضبط
  (write-line "dlg_mode_select : dialog {" f)
  (write-line "  label = \"أداة فحص ودمج البلوكات الاحترافية\";" f)
  (write-line "  : boxed_radio_column {" f)
  (write-line "    label = \"نطاق العمل المطلوب\";" f)
  (write-line "    : radio_button { key = \"rb_pick\"; label = \"تحديد مجموعة عناصر من الشاشة (Select Objects)\"; value = \"1\"; }" f)
  (write-line "    : radio_button { key = \"rb_all\";  label = \"حصر وفحص كامل مساحة المخطط (Entire Drawing)\"; }" f)
  (write-line "  }" f)
  (write-line "  : boxed_row {" f)
  (write-line "    label = \"عتبة مطابقة الأسماء\";" f)
  (write-line "    : text { label = \"نسبة التشابه الإسمي الأدنى (%):\"; }" f)
  (write-line "    : edit_box { key = \"eb_thresh\"; value = \"90\"; edit_width = 5; }" f)
  (write-line "  }" f)
  (write-line "  : spacer { height = 1; }" f)
  (write-line "  : row {" f)
  (write-line "    alignment = centered; fixed_width = true;" f)
  (write-line "    : button { key = \"accept\"; label = \"بدء الفحص والتحليل\"; is_default = true; width = 16; }" f)
  (write-line "    : button { key = \"cancel\"; label = \"إلغاء\"; is_cancel = true; width = 12; }" f)
  (write-line "  }" f)
  (write-line "}" f)

  ;; شاشة الحصر والمعاينة
  (write-line "dlg_blk_dashboard : dialog {" f)
  (write-line "  label = \"لوحة الحصر الهندسي والمعاينة المتجهة للبلوكات\";" f)
  (write-line "  : row {" f)
  (write-line "    : column {" f)
  (write-line "      : text { label = \"مجموعات البلوكات المتشابهة وحالة التطابق الهندسية:\"; }" f)
  (write-line "      : list_box { key = \"main_list\"; width = 90; height = 23; fixed_width_font = true; }" f)
  (write-line "    }" f)
  (write-line "    : boxed_column {" f)
  (write-line "      label = \"المعاينة والتدقيق الهندسي\"; width = 45;" f)
  (write-line "      : image { key = \"prev_box\"; width = 42; height = 13; color = 0; }" f)
  (write-line "      : spacer { height = 1; }" f)
  (write-line "      : text { key = \"lbl_selected_name\"; label = \"البلوك: --\"; fixed_width = true; width = 42; }" f)
  (write-line "      : text { key = \"lbl_geo_status\";   label = \"التطابق الداخلي: --\"; }" f)
  (write-line "      : text { key = \"lbl_ent_details\"; label = \"المحتوى: --\"; }" f)
  (write-line "      : text { key = \"lbl_dims\";        label = \"الأبعاد: --\"; }" f)
  (write-line "    }" f)
  (write-line "  }" f)
  (write-line "  : text { key = \"audit_summary\"; value = \"\"; }" f)
  (write-line "  : spacer { height = 1; }" f)
  (write-line "  : row {" f)
  (write-line "    alignment = centered; fixed_width = true;" f)
  (write-line "    : button { key = \"btn_execute\"; label = \"اعتماد ودمج البلوكات\"; is_default = true; width = 20; }" f)
  (write-line "    : button { key = \"cancel\"; label = \"إلغاء الخروج\"; is_cancel = true; width = 14; }" f)
  (write-line "  }" f)
  (write-line "}" f)

  (close f)
  path)

;;; ================================================================
;;; 6. الأمر الرئيسي: BLK90
;;; ================================================================
(defun c:BLK90 (/ dcl-file dcl-id step1-ans sel-mode th-val th-ratio
                  ss i ent bname blk-registry sorted-registry clusters
                  master-blk m-name m-ents matched-group remaining
                  cur-sim master-sig cur-sig geo-check disp-entries
                  entry-map item-idx merge-candidates-cnt step2-ans doc)

  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq dcl-file (build-advanced-dcl)
        dcl-id   (load_dialog dcl-file))

  ;; 1. ظهور مربع الحوار لتحديد الخيارات أولاً
  (if (new_dialog "dlg_mode_select" dcl-id)
    (progn
      (action_tile "accept"
        "(setq sel-mode (get_tile \"rb_pick\")
               th-val   (get_tile \"eb_thresh\"))
         (done_dialog 1)")
      (action_tile "cancel" "(done_dialog 0)")
      (setq step1-ans (start_dialog)))
    (princ "\nتعذر تحميل نافذة الإعدادات."))

  (setq th-ratio (if (and th-val (distof th-val))
                   (/ (distof th-val) 100.0)
                   0.90))

  ;; 2. طلب التحديد من المستخدم
  (if (= step1-ans 1)
    (progn
      (if (= sel-mode "1")
        (progn
          (princ "\nحدد البلوكات المطلوبة من المخطط (اضغط Enter لاختيار كامل الرسم تلقائياً): ")
          (setq ss (ssget '((0 . "INSERT"))))
          (if (not ss) (setq ss (ssget "_X" '((0 . "INSERT"))))))
        (setq ss (ssget "_X" '((0 . "INSERT")))))

      (if (not ss)
        (princ "\nلم يتم العثور على أي بلوكات في نطاق التحديد.")
        (progn
          ;; تجميع البلوكات وتكرارها
          (setq blk-registry nil)
          (repeat (setq i (sslength ss))
            (setq ent (ssname ss (setq i (1- i)))
                  bname (get-blk-real-name ent))
            (if (not (wcmatch bname "`**"))
              (if (assoc bname blk-registry)
                (setq blk-registry (subst (cons bname (cons ent (cdr (assoc bname blk-registry))))
                                          (assoc bname blk-registry)
                                          blk-registry))
                (setq blk-registry (cons (cons bname (list ent)) blk-registry)))))

          ;; فرز البلوكات حسب الأكثر تكراراً لتكون هي الأساس (Master)
          (setq sorted-registry
                (vl-sort blk-registry
                         '(lambda (a b) (> (length (cdr a)) (length (cdr b))))))

          ;; التحليل المزدوج: نسبة تطابق الاسم + التدقيق الهندسي الداخلي
          (setq clusters nil)
          (while sorted-registry
            (setq master-blk (car sorted-registry)
                  m-name     (car master-blk)
                  m-ents     (cdr master-blk)
                  matched-group nil
                  remaining     nil
                  master-sig (get-blk-geo-sig m-name))

            (foreach cand (cdr sorted-registry)
              (setq cur-sim (get-str-similarity m-name (car cand)))
              (if (>= cur-sim th-ratio)
                (progn
                  (setq cur-sig   (get-blk-geo-sig (car cand))
                        geo-check (compare-blk-geo master-sig cur-sig))
                  (setq matched-group
                        (cons (list (car cand) (cdr cand) cur-sim geo-check cur-sig)
                              matched-group)))
                (setq remaining (cons cand remaining))))

            (setq clusters (cons (list m-name m-ents master-sig matched-group) clusters)
                  sorted-registry (reverse remaining)))

          ;; بناء بيانات العرض وربطها مع المعاينة
          (setq disp-entries nil
                entry-map    nil
                merge-candidates-cnt 0
                item-idx 0)

          (foreach cl (reverse clusters)
            (setq m-name   (nth 0 cl)
                  m-cnt    (length (nth 1 cl))
                  m-sig    (nth 2 cl)
                  sub-list (nth 3 cl))
            
            (if sub-list
              (progn
                (setq tot-cnt m-cnt)
                (foreach s sub-list (setq tot-cnt (+ tot-cnt (length (cadr s)))))
                
                (setq disp-entries (cons (strcat "[*] [معتمد] " m-name " (العدد: " (itoa m-cnt) " -> بعد الدمج: " (itoa tot-cnt) ")") disp-entries))
                (setq entry-map (cons (cons item-idx (list m-name m-sig "البلوك الرئيسي المعتمد")) entry-map))
                (setq item-idx (1+ item-idx))

                (foreach s sub-list
                  (setq merge-candidates-cnt (+ merge-candidates-cnt (length (cadr s))))
                  (setq geo-res (nth 3 s))
                  (setq tag-symbol (if (= (cadr geo-res) "MATCH") "[OK]" "[!]"))
                  (setq disp-entries
                        (cons (strcat "   " tag-symbol " يدمج: " (car s)
                                     " | عدد: " (itoa (length (cadr s)))
                                     " | إسمي: " (rtos (* (nth 2 s) 100.0) 2 0) "%"
                                     " | رسم: " (car geo-res))
                              disp-entries))
                  (setq entry-map (cons (cons item-idx (list (car s) (nth 4 s) (car geo-res))) entry-map))
                  (setq item-idx (1+ item-idx)))
                
                (setq disp-entries (cons "--------------------------------------------------------------------------------" disp-entries))
                (setq entry-map (cons (cons item-idx nil) entry-map))
                (setq item-idx (1+ item-idx)))
              (progn
                (setq disp-entries (cons (strcat "[-] [منفرد] " m-name " (العدد: " (itoa m-cnt) ")") disp-entries))
                (setq entry-map (cons (cons item-idx (list m-name m-sig "بلوك منفرد بدون تشابه")) entry-map))
                (setq item-idx (1+ item-idx)))))

          (setq disp-entries (reverse disp-entries))

          ;; دالة تحديث بطاقة المعاينة والتدقيق
          (defun update-preview-card (idx / rec b-target b-sig b-status type-summary)
            (setq rec (cdr (assoc idx entry-map)))
            (if (and rec (car rec))
              (progn
                (setq b-target (nth 0 rec)
                      b-sig    (nth 1 rec)
                      b-status (nth 2 rec))
                (set_tile "lbl_selected_name" (strcat "البلوك: " (substr b-target 1 35)))
                (set_tile "lbl_geo_status"   (strcat "التطابق: " b-status))
                (if b-sig
                  (progn
                    (setq type-summary "")
                    (foreach tp (nth 1 b-sig)
                      (setq type-summary (strcat type-summary (car tp) ":" (itoa (cdr tp)) " ")))
                    (set_tile "lbl_ent_details" (strcat "العناصر (" (itoa (nth 0 b-sig)) "): " type-summary))
                    (set_tile "lbl_dims" (strcat "الأبعاد: X=" (rtos (nth 2 b-sig) 2 2) "  Y=" (rtos (nth 3 b-sig) 2 2))))
                  (progn
                    (set_tile "lbl_ent_details" "المحتوى: لا توجد بيانات")
                    (set_tile "lbl_dims" "الأبعاد: --")))
                (draw-block-preview b-target "prev_box"))
              (progn
                (set_tile "lbl_selected_name" "البلوك: --")
                (set_tile "lbl_geo_status" "التطابق: --")
                (set_tile "lbl_ent_details" "المحتوى: --")
                (set_tile "lbl_dims" "الأبعاد: --"))))

          ;; 3. فتح شاشة الحصر ولوحة التحكم
          (if (new_dialog "dlg_blk_dashboard" dcl-id)
            (progn
              (start_list "main_list")
              (mapcar 'add_list disp-entries)
              (end_list)

              (set_tile "audit_summary"
                        (strcat "إجمالي الكيانات: " (itoa (sslength ss))
                                "  |  البلوكات المستهدفة للدمج: " (itoa merge-candidates-cnt)
                                "  |  عتبة التشابه: " (rtos (* th-ratio 100.0) 2 0) "%"))

              (update-preview-card 0)

              (action_tile "main_list" "(update-preview-card (atoi $value))")
              (action_tile "btn_execute" "(done_dialog 1)")
              (action_tile "cancel" "(done_dialog 0)")

              (setq step2-ans (start_dialog)))
            (princ "\nتعذر تحميل شاشة الحصر."))

          ;; 4. تنفيذ الدمج عند الاعتماد
          (if (= step2-ans 1)
            (progn
              (vla-startundomark doc)
              (foreach cl clusters
                (setq m-name   (nth 0 cl)
                      sub-list (nth 3 cl))
                (foreach s sub-list
                  (foreach ent (cadr s)
                    (setq ed (entget ent))
                    (setq ed (subst (cons 2 m-name) (assoc 2 ed) ed))
                    (entmod ed)
                    (entupd ent))))
              (vla-endundomark doc)
              (vla-regen doc 1) ; تجديد آمن للرسم
              (princ (strcat "\nتم الانتهاء بنجاح: تم دمج " (itoa merge-candidates-cnt) " بلوك إلى التسميات المعتمدة.")))
            (princ "\nتم إلغاء الدمج ولم يتم تعديل أي عنصر."))
        ))))

  (unload_dialog dcl-id)
  (if (findfile dcl-file) (vl-file-delete dcl-file))
  (princ)
)

(princ "\nتم التحديث بنجاح. اكتب BLK90 للتشغيل.")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:B90 () (c:BLK90))
