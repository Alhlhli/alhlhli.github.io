;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: BMG
;;; الملف الأصلي: ‏‏BlockManager - نسخة (15).LSP
;;; ===========================================================================
;;; أداة إدارة واستبدال البلوكات الاحترافية + تعديل الوحدات ونقطة الإدراج
;;; م/ عامر - المكتب الفني
;;; ===========================================================================
(vl-load-com)

(defun c:BlockManager (/ *error* doc dcl_id action old_blk new_blk selected_unit
                        temp_dcl dcl_handle result ss_init info_msg old_echo
                        old_regen ent_name units_list update-ui-modes)

  ;; --- قائمة الوحدات القياسية في أوتوكاد ---
  (setq units_list
   '("0 - Unitless (بدون وحدة)"
     "1 - Inches (بوصة)"
     "2 - Feet (قدم)"
     "3 - Miles (ميل)"
     "4 - Millimeters (ميليمتر)"
     "5 - Centimeters (سنتيمتر)"
     "6 - Meters (متر)"
     "7 - Kilometers (كيلومتر)"
     "8 - Microinches"
     "9 - Mils"
     "10 - Yards (ياردة)"
     "11 - Angstroms"
     "12 - Nanometers"
     "13 - Microns"
     "14 - Decimeters (ديسيمتر)"
     "15 - Decameters"
     "16 - Hectometers"
     "17 - Gigameters"
     "18 - Astronomical Units"
     "19 - Light Years"
     "20 - Parsecs"
     "21 - US Survey Feet"))

  ;; --- معالج الأخطاء ---
  (defun *error* (msg)
    (if dcl_id (unload_dialog dcl_id))
    (if (and temp_dcl (findfile temp_dcl)) (vl-file-delete temp_dcl))
    (if doc (vla-EndUndoMark doc))
    (if old_echo (setvar "CMDECHO" old_echo))
    (if old_regen (setvar "REGENMODE" old_regen))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\n[خطأ]: " msg)))
    (princ)
  )

  ;; --- استخراج الاسم الفعلي للبلوك (بما فيه الديناميكي) ---
  (defun get-block-effective-name (ent / obj)
    (if (and ent (setq obj (vlax-ename->vla-object ent)))
      (if (and (vlax-property-available-p obj 'IsDynamicBlock)
               (= (vla-get-IsDynamicBlock obj) :vlax-true))
        (vla-get-EffectiveName obj)
        (cdr (assoc 2 (entget ent))))
      nil)
  )

  ;; --- جلب وحدة البلوك الحالية من جدول التعريفات ---
  (defun get-block-unit-code (blkname / blks blk_def u)
    (setq blks (vla-get-Blocks (vla-get-ActiveDocument (vlax-get-acad-object))))
    (if (not (vl-catch-all-error-p (setq blk_def (vl-catch-all-apply 'vla-Item (list blks blkname)))))
      (if (vlax-property-available-p blk_def 'Units)
        (vla-get-Units blk_def)
        0)
      0)
  )

  ;; --- انتقاء بلوك صالح من الشاشة ---
  (defun pick-block-prompt (prompt_msg / ent ed bname)
    (setq bname nil)
    (while (and (not bname) (setq ent (entsel prompt_msg)))
      (setq ed (entget (car ent)))
      (if (= (cdr (assoc 0 ed)) "INSERT")
        (setq bname (get-block-effective-name (car ent)))
        (princ "\n[!] العنصر المحدد ليس بلوك. يرجى اختيار بلوك صالح.")))
    bname
  )

  ;; --- جلب بيانات وإحصائيات البلوك ---
  (defun get-block-stats (blk / ss obj is_dyn count atts u_code u_name)
    (if (or (null blk) (= blk ""))
      "يرجى تحديد بلوك لعرض بياناته"
      (progn
        (setq count 0 is_dyn "لا" atts "لا" u_code (get-block-unit-code blk))
        (setq u_name (if (< u_code (length units_list)) (nth u_code units_list) "غير محدد"))
        (if (setq ss (ssget "_X" (list '(0 . "INSERT") (cons 2 (strcat blk ",`*U*")))))
          (progn
            (setq i 0)
            (repeat (sslength ss)
              (setq obj (vlax-ename->vla-object (ssname ss i)))
              (if (= (strcase (get-block-effective-name (ssname ss i))) (strcase blk))
                (setq count (1+ count)))
              (setq i (1+ i)))))
        (if (and ss (> count 0) (setq obj (vlax-ename->vla-object (ssname ss 0))))
          (progn
            (if (= (vla-get-HasAttributes obj) :vlax-true) (setq atts "نعم"))
            (if (vlax-property-available-p obj 'IsDynamicBlock)
              (if (= (vla-get-IsDynamicBlock obj) :vlax-true) (setq is_dyn "نعم")))))
        (strcat "العدد: " (itoa count) " | خصائص: " atts " | ديناميكي: " is_dyn " | الوحدة: " u_name)
      )
    )
  )

  ;; --- الإعدادات الأولية ---
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark doc)
  (setq old_echo (getvar "CMDECHO") old_regen (getvar "REGENMODE"))
  (setvar "CMDECHO" 0)

  ;; --- فحص التحديد المسبق ---
  (setq ss_init (ssget "_I" '((0 . "INSERT"))))
  (if ss_init
    (progn
      (setq old_blk (get-block-effective-name (ssname ss_init 0)))
      (setq info_msg (get-block-stats old_blk))
      (setq selected_unit (itoa (get-block-unit-code old_blk))))
    (setq old_blk "" info_msg "يرجى تحديد بلوك لعرض بياناته" selected_unit "0"))
  (setq new_blk "" action "act_rename")

  ;; --- إنشاء الواجهة DCL ---
  (setq temp_dcl (vl-filename-mktemp "bm_pro" nil ".dcl"))
  (setq dcl_handle (open temp_dcl "w"))
  (write-line "bm_dialog : dialog { label = \"مدير البلوكات الاحترافي - م/ عامر\";" dcl_handle)
  (write-line " : boxed_column { label = \"البلوك المستهدف\";" dcl_handle)
  (write-line " : row {" dcl_handle)
  (write-line " : edit_box { label = \"اسم البلوك:\"; key = \"eb_old\"; edit_width = 25; }" dcl_handle)
  (write-line " : button { label = \"تحديد\"; key = \"btn_pick_old\"; width = 8; }" dcl_handle)
  (write-line " }" dcl_handle)
  (write-line " : text { key = \"txt_info\"; alignment = centered; }" dcl_handle)
  (write-line " }" dcl_handle)
  (write-line " : boxed_radio_column { label = \"نوع العملية\"; key = \"rb_action\";" dcl_handle)
  (write-line " : radio_button { label = \"إعادة تسمية البلوك (Rename)\"; key = \"act_rename\"; }" dcl_handle)
  (write-line " : radio_button { label = \"استبدال كلي ببلوك آخر (Replace)\"; key = \"act_replace\"; }" dcl_handle)
  (write-line " : radio_button { label = \"تغيير نقطة الإدراج (Base Point)\"; key = \"act_base\"; }" dcl_handle)
  (write-line " : radio_button { label = \"تغيير وحدة تعريف البلوك (Block Units)\"; key = \"act_units\"; }" dcl_handle)
  (write-line " }" dcl_handle)
  (write-line " : boxed_column { label = \"الخيارات والبيانات\";" dcl_handle)
  (write-line " : row {" dcl_handle)
  (write-line " : edit_box { label = \"الاسم الجديد / البديل:\"; key = \"eb_new\"; edit_width = 25; }" dcl_handle)
  (write-line " : button { label = \"تحديد\"; key = \"btn_pick_new\"; width = 8; }" dcl_handle)
  (write-line " }" dcl_handle)
  (write-line " : popup_list { label = \"وحدة البلوك الجديدة:\"; key = \"pop_units\"; edit_width = 25; }" dcl_handle)
  (write-line " }" dcl_handle)
  (write-line " : spacer { height = 1; }" dcl_handle)
  (write-line " : row { fixed_width = true; alignment = centered;" dcl_handle)
  (write-line " : button { label = \"تنفيذ\"; key = \"accept\"; is_default = true; width = 14; }" dcl_handle)
  (write-line " : button { label = \"إلغاء\"; key = \"cancel\"; is_cancel = true; width = 14; }" dcl_handle)
  (write-line " }" dcl_handle)
  (write-line "}" dcl_handle)
  (close dcl_handle)

  ;; --- دالة تحديث حالة الحقول بالواجهة ---
  (defun update-ui-modes (act)
    (cond
      ((= act "act_rename")
       (mode_tile "eb_new" 0) (mode_tile "btn_pick_new" 1) (mode_tile "pop_units" 1))
      ((= act "act_replace")
       (mode_tile "eb_new" 0) (mode_tile "btn_pick_new" 0) (mode_tile "pop_units" 1))
      ((= act "act_base")
       (mode_tile "eb_new" 1) (mode_tile "btn_pick_new" 1) (mode_tile "pop_units" 1))
      ((= act "act_units")
       (mode_tile "eb_new" 1) (mode_tile "btn_pick_new" 1) (mode_tile "pop_units" 0))
    )
  )

  ;; --- تشغيل الواجهة وإدارتها ---
  (setq dcl_id (load_dialog temp_dcl) result 2)

  (while (> result 1)
    (if (not (new_dialog "bm_dialog" dcl_id)) (exit))

    (start_list "pop_units")
    (mapcar 'add_list units_list)
    (end_list)

    (set_tile "eb_old" (if old_blk old_blk ""))
    (set_tile "eb_new" (if new_blk new_blk ""))
    (set_tile "txt_info" (if info_msg info_msg ""))
    (set_tile "pop_units" selected_unit)
    (set_tile action "1")

    (update-ui-modes action)

    (action_tile "act_rename"  "(setq action \"act_rename\") (update-ui-modes action)")
    (action_tile "act_replace" "(setq action \"act_replace\") (update-ui-modes action)")
    (action_tile "act_base"    "(setq action \"act_base\") (update-ui-modes action)")
    (action_tile "act_units"   "(setq action \"act_units\") (update-ui-modes action)")

    (action_tile "pop_units"   "(setq selected_unit $value)")

    (action_tile "btn_pick_old"
      "(setq old_blk (get_tile \"eb_old\") new_blk (get_tile \"eb_new\") selected_unit (get_tile \"pop_units\")) (done_dialog 2)")
    (action_tile "btn_pick_new"
      "(setq old_blk (get_tile \"eb_old\") new_blk (get_tile \"eb_new\") selected_unit (get_tile \"pop_units\")) (done_dialog 3)")

    (action_tile "accept"
      "(setq old_blk (get_tile \"eb_old\") new_blk (get_tile \"eb_new\") selected_unit (get_tile \"pop_units\")) (done_dialog 1)")
    (action_tile "cancel" "(done_dialog 0)")

    (setq result (start_dialog))

    (cond
      ((= result 2)
       (if (setq ent_name (pick-block-prompt "\nاختر البلوك المستهدف: "))
         (progn
           (setq old_blk ent_name)
           (setq info_msg (get-block-stats old_blk))
           (setq selected_unit (itoa (get-block-unit-code old_blk))))))
      ((= result 3)
       (if (setq ent_name (pick-block-prompt "\nاختر البلوك البديل: "))
         (setq new_blk ent_name))))
  )

  ;; --- تنفيذ الإجراءات المختارة ---
  (if (and (= result 1) old_blk (/= old_blk ""))
    (progn
      (setvar "REGENMODE" 0)
      (cond
        ;; 1. إعادة التسمية
        ((= action "act_rename")
         (if (and new_blk (/= new_blk "") (tblsearch "BLOCK" old_blk))
           (if (not (tblsearch "BLOCK" new_blk))
             (progn
               (command "_.RENAME" "_B" old_blk new_blk)
               (princ (strcat "\n[✔] تم تغيير اسم البلوك إلى: " new_blk)))
             (princ "\n[!] الاسم الجديد مستخدم مسبقاً."))
           (princ "\n[!] تحقق من صحة الأسماء المدخلة.")))

        ;; 2. الاستبدال الكلي
        ((= action "act_replace")
         (if (and (tblsearch "BLOCK" old_blk) (tblsearch "BLOCK" new_blk))
           (execute-fast-replace old_blk new_blk)
           (princ "\n[!] تعذر الاستبدال، تأكد من وجود كلا البلوكين في الرسم.")))

        ;; 3. تغيير نقطة الإدراج
        ((= action "act_base")
         (change-insertion-base old_blk))

        ;; 4. تغيير وحدة البلوك في جدول التعريفات
        ((= action "act_units")
         (set-block-definition-units old_blk (atoi selected_unit) (nth (atoi selected_unit) units_list)))
      )
      (setvar "REGENMODE" old_regen)
      (command "_.REGEN")
    )
  )

  ;; تنظيف الذاكرة
  (if dcl_id (unload_dialog dcl_id))
  (if (and temp_dcl (findfile temp_dcl)) (vl-file-delete temp_dcl))
  (setvar "CMDECHO" old_echo)
  (vla-EndUndoMark doc)
  (princ)
)

;; ────────────────────────────────────────────────
;; دالة تعديل وحدة تعريف البلوك (Block Units)
;; ────────────────────────────────────────────────
(defun set-block-definition-units (blkname unit_code unit_label / doc blks blk_def)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object))
        blks (vla-get-Blocks doc))
  (if (vl-catch-all-error-p (setq blk_def (vl-catch-all-apply 'vla-Item (list blks blkname))))
    (princ "\n[!] تعذر العثور على تعريف البلوك في ملف الرسم.")
    (progn
      (if (vlax-property-available-p blk_def 'Units)
        (progn
          (vla-put-Units blk_def unit_code)
          (princ (strcat "\n[✔] تم تغيير وحدة البلوك [" blkname "] بنجاح إلى: " unit_label)))
        (princ "\n[!] خاصية Units غير مدعومة لهذا العنصر.")))))

;; ────────────────────────────────────────────────
;; دالة الاستبدال السريع مع الحفاظ على الخصائص
;; ────────────────────────────────────────────────
(defun execute-fast-replace (old new / ss i en obj att_map tag val ed eff_name count)
  (setq ss (ssget "_X" (list '(0 . "INSERT") (cons 2 (strcat old ",`*U*"))))
        count 0)
  (if ss
    (progn
      (setq i 0)
      (repeat (sslength ss)
        (setq en (ssname ss i) obj (vlax-ename->vla-object en))
        (setq eff_name (if (and (vlax-property-available-p obj 'IsDynamicBlock)
                                (= (vla-get-IsDynamicBlock obj) :vlax-true))
                         (vla-get-EffectiveName obj)
                         (cdr (assoc 2 (entget en)))))
        (if (= (strcase eff_name) (strcase old))
          (progn
            (setq att_map nil)
            (if (= (vla-get-HasAttributes obj) :vlax-true)
              (foreach att (vlax-invoke obj 'GetAttributes)
                (setq att_map (cons (cons (vla-get-TagString att) (vla-get-TextString att)) att_map))))
            (setq ed (entget en))
            (entmod (subst (cons 2 new) (assoc 2 ed) ed))
            (if (and att_map (= (vla-get-HasAttributes obj) :vlax-true))
              (foreach att (vlax-invoke obj 'GetAttributes)
                (setq tag (vla-get-TagString att))
                (if (setq val (assoc tag att_map)) (vla-put-TextString att (cdr val)))))
            (setq count (1+ count))))
        (setq i (1+ i)))
      (princ (strcat "\n[✔] تم استبدال " (itoa count) " نسخة بنجاح.")))
    (princ "\n[!] لم يتم العثور على أي نسخ للاستبدال."))
  (princ)
)

;; ────────────────────────────────────────────────
;; دالة تعديل نقطة الإدراج
;; ────────────────────────────────────────────────
(defun change-insertion-base (blkname / ss i ent obj minpt maxpt minp maxp ctr old_ins pt_new mode dx dy)
  (princ "\n┌──────────────────────────────────────────────┐")
  (princ "\n│          تغيير نقطة إدراج البلوك             │")
  (princ "\n└──────────────────────────────────────────────┘")
  (initget "1 2 3")
  (setq mode (getkword "\nاختر الطريقة [1: مركز المحيط | 2: نقطة محددة | 3: إزاحة X/Y]: "))

  (if (not mode) (setq mode "1"))
  (setq ss (ssget "_X" (list '(0 . "INSERT") (cons 2 blkname))))
  (if (not ss)
    (princ "\n[!] لا توجد نسخ من هذا البلوك في الرسم.")
    (cond
      ((= mode "1")
       (setq i 0)
       (repeat (sslength ss)
         (setq ent (ssname ss i) obj (vlax-ename->vla-object ent))
         (vla-getboundingbox obj 'minpt 'maxpt)
         (setq minp (vlax-safearray->list minpt)
               maxp (vlax-safearray->list maxpt)
               ctr  (mapcar '/ (mapcar '+ minp maxp) '(2.0 2.0 2.0)))
         (entupd (entmod (subst (cons 10 ctr) (assoc 10 (entget ent)) (entget ent))))
         (setq i (1+ i)))
       (princ (strcat "\n[✔] تم ضبط مركز المحيط لـ " (itoa i) " عنصر.")))

      ((= mode "2")
       (if (setq pt_new (getpoint "\nحدد النقطة الجديدة للإدراج: "))
         (progn
           (setq i 0)
           (repeat (sslength ss)
             (setq ent (ssname ss i))
             (entmod (subst (cons 10 pt_new) (assoc 10 (entget ent)) (entget ent)))
             (setq i (1+ i)))
           (princ (strcat "\n[✔] تم تعديل موقع " (itoa i) " بلوك إلى النقطة المختارة.")))
         (princ "\n[!] تم إلغاء تحديد النقطة.")))

      ((= mode "3")
       (setq dx (getreal "\nقيمة الإزاحة في X <0>: ")
             dy (getreal "\nقيمة الإزاحة في Y <0>: "))
       (setq dx (if dx dx 0.0) dy (if dy dy 0.0))
       (setq i 0)
       (repeat (sslength ss)
         (setq ent (ssname ss i)
               old_ins (cdr (assoc 10 (entget ent)))
               new_ins (list (+ (car old_ins) dx) (+ (cadr old_ins) dy) (caddr old_ins)))
         (entmod (subst (cons 10 new_ins) (assoc 10 (entget ent)) (entget ent)))
         (setq i (1+ i)))
       (princ (strcat "\n[✔] تمت إزاحة " (itoa i) " بلوك بمقدار (" (rtos dx 2 2) ", " (rtos dy 2 2) ").")))))
  (princ)
)

(princ "\nتم تحميل Block Manager PRO بنجاح. اكتب BlockManager للبدء.")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:BMG () (c:BlockManager))
