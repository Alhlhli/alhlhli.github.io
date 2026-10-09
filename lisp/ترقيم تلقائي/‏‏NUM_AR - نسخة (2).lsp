;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: NMR
;;; الملف الأصلي: ‏‏NUM_AR - نسخة (2).lsp
(defun c:NUM_PRO (/ dcl_id pt start_num prefix suffix hgt counter text_val styl_list lay_list cur_styl cur_lay justify)
  (vl-load-com)
  
  ;; 1. جلب قائمة الاستايلات والطبقات من الرسمة
  (setq styl_list '() lay_list '())
  (setq st (tblnext "STYLE" T))
  (while st (setq styl_list (cons (cdr (assoc 2 st)) styl_list) st (tblnext "STYLE")))
  (setq ly (tblnext "LAYER" T))
  (while ly (setq lay_list (cons (cdr (assoc 2 ly)) lay_list) ly (tblnext "LAYER")))
  (setq styl_list (acad_strlsort styl_list) lay_list (acad_strlsort lay_list))

  ;; 2. إنشاء واجهة DCL متطورة
  (setq f (open (setq dcl_file (vl-filename-mktemp "" "" ".dcl")) "w"))
  (write-line "num_pro_dlg : dialog { label = \"نظام الترقيم الذكي - م/ عامر\";" f)
  (write-line " : row { " f)
  (write-line "   : column { " f)
  (write-line "     : popup_list { label = \"ستايل النص:\"; key = \"pop_styl\"; width = 20; }" f)
  (write-line "     : popup_list { label = \"الطبقة (Layer):\"; key = \"pop_lay\"; width = 20; }" f)
  (write-line "   }" f)
  (write-line "   : boxed_column { label = \"المحاذاة (9 نقاط)\";" f)
  (write-line "     : radio_row { " f)
  (write-line "       : radio_button { label=\"TL\"; key=\"TL\"; } : radio_button { label=\"TC\"; key=\"TC\"; } : radio_button { label=\"TR\"; key=\"TR\"; }" f)
  (write-line "     } : radio_row { " f)
  (write-line "       : radio_button { label=\"ML\"; key=\"ML\"; } : radio_button { label=\"MC\"; key=\"MC\"; value=\"1\"; } : radio_button { label=\"MR\"; key=\"MR\"; }" f)
  (write-line "     } : radio_row { " f)
  (write-line "       : radio_button { label=\"BL\"; key=\"BL\"; } : radio_button { label=\"BC\"; key=\"BC\"; } : radio_button { label=\"BR\"; key=\"BR\"; }" f)
  (write-line "     } " f)
  (write-line "   }" f)
  (write-line " } " f)
  (write-line " : row { " f)
  (write-line "   : edit_box { label = \"البداية:\"; key = \"eb_start\"; edit_width = 5; }" f)
  (write-line "   : edit_box { label = \"قبل:\"; key = \"eb_pre\"; edit_width = 8; }" f)
  (write-line "   : edit_box { label = \"بعد:\"; key = \"eb_suf\"; edit_width = 8; }" f)
  (write-line "   : edit_box { label = \"الارتفاع:\"; key = \"eb_hgt\"; edit_width = 5; }" f)
  (write-line " } " f)
  (write-line " ok_cancel; }" f)
  (close f)

  ;; 3. تحميل الواجهة وبرمجة التفاعلات
  (setq dcl_id (load_dialog dcl_file))
  (if (not (new_dialog "num_pro_dlg" dcl_id)) (exit))
  
  (start_list "pop_styl") (mapcar 'add_list styl_list) (end_list)
  (start_list "pop_lay") (mapcar 'add_list lay_list) (end_list)
  (set_tile "eb_start" "1")
  (set_tile "eb_hgt" (rtos (getvar "TEXTSIZE") 2 2))
  (setq justify "MC")

  (action_tile "TL" "(setq justify \"TL\")") (action_tile "TC" "(setq justify \"TC\")") (action_tile "TR" "(setq justify \"TR\")")
  (action_tile "ML" "(setq justify \"ML\")") (action_tile "MC" "(setq justify \"MC\")") (action_tile "MR" "(setq justify \"MR\")")
  (action_tile "BL" "(setq justify \"BL\")") (action_tile "BC" "(setq justify \"BC\")") (action_tile "BR" "(setq justify \"BR\")")

  (action_tile "accept" 
    "(setq start_num (atoi (get_tile \"eb_start\")) 
           prefix (get_tile \"eb_pre\") 
           suffix (get_tile \"eb_suf\") 
           hgt (atof (get_tile \"eb_hgt\"))
           cur_styl (nth (atoi (get_tile \"pop_styl\")) styl_list)
           cur_lay (nth (atoi (get_tile \"pop_lay\")) lay_list)) (done_dialog 1)")

  ;; 4. التنفيذ في الرسمة
  (if (= (start_dialog) 1)
    (progn
      (setq counter start_num)
      (setvar "CLAYER" cur_lay)
      (setvar "TEXTSTYLE" cur_styl)
      (while (setq pt (getpoint "\nاختر نقطة الإدراج: "))
        (setq text_val (strcat prefix (itoa counter) suffix))
        (command "_text" "J" justify pt hgt 0 text_val)
        (setq counter (1+ counter))
      )
    )
  )
  (unload_dialog dcl_id)
  (vl-file-delete dcl_file)
  (princ)
)
;;; اختصار من ثلاثة أحرف.
(defun c:NMR () (c:NUM_PRO))
