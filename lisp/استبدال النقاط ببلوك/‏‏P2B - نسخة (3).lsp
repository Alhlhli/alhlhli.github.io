;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: P2B
;;; الملف الأصلي: ‏‏P2B - نسخة (3).lsp
(defun c:P2B (/ dcl_id dcl_file f action ss i ent data pt lay blk_name 
                        scl_min scl_max ran_scl ran_rot del_pt lay_opt flat_z cur_scl cur_rot)
  (vl-load-com)
  
  ;; --- دالة توليد الأرقام العشوائية (رياضية بحتة لضمان التغيير) ---
  (if (not *seed*) (setq *seed* (getvar "DATE")))
  (defun my-rand ()
    (setq *seed* (rem (+ (* *seed* 214013) 2531011) 4294967296))
    (/ *seed* 4294967296.0)
  )

  ;; إعدادات افتراضية
  (setq g_blk (if g_blk g_blk ""))
  (setq g_scl_min (if g_scl_min g_scl_min "1.0"))
  (setq g_scl_max (if g_scl_max g_scl_max "1.5"))

  ;; 1. إنشاء ملف الواجهة DCL
  (setq dcl_file (vl-filename-mktemp "p2b_ult.dcl"))
  (setq f (open dcl_file "w"))
  (foreach line '(
    "p2b_ult : dialog { label = \"إدارة المكتب الفني - استبدال متطور v2.0\";"
    "  : boxed_column { label = \"البلوك المرجعي\";"
    "    : row { : edit_box { label = \"اسم البلوك:\"; key = \"eb_blk\"; edit_width = 25; } : button { label = \"إمساك >\"; key = \"btn_pick\"; } }"
    "  }"
    "  : row {"
    "    : boxed_column { label = \"المقياس (Scale)\";"
    "      : edit_box { label = \"الحد الأدنى:\"; key = \"eb_scl_min\"; }"
    "      : edit_box { label = \"الحد الأقصى:\"; key = \"eb_scl_max\"; }"
    "      : toggle { label = \"عشوائية المقياس\"; key = \"tg_ran_scl\"; }"
    "    }"
    "    : boxed_column { label = \"الدوران (Rotation)\";"
    "      : toggle { label = \"تدوير عشوائي (0-360)\"; key = \"tg_ran_rot\"; }"
    "      : edit_box { label = \"زاوية ثابتة:\"; key = \"eb_rot_fix\"; }"
    "    }"
    "  }"
    "  : boxed_column { label = \"خيارات التنفيذ\";"
    "    : row {"
    "      : toggle { label = \"منسوب Z=0\"; key = \"tg_flat\"; }"
    "      : toggle { label = \"نفس الطبقة\"; key = \"tg_lay\"; value=\"1\"; }"
    "      : toggle { label = \"حذف النقطة\"; key = \"tg_del\"; value=\"1\"; }"
    "    }"
    "    : button { label = \"تحديد النقاط من الرسم\"; key = \"btn_ss\"; height = 2; }"
    "  }"
    "  ok_cancel;"
    "}"
  ) (write-line line f))
  (close f)

  ;; 2. إدارة الواجهة
  (setq dcl_id (load_dialog dcl_file))
  (setq action 2)
  (while (> action 1)
    (if (not (new_dialog "p2b_ult" dcl_id)) (exit))
    (set_tile "eb_blk" g_blk) (set_tile "eb_scl_min" g_scl_min) (set_tile "eb_scl_max" g_scl_max)
    (action_tile "btn_pick" "(setq g_blk (get_tile \"eb_blk\")) (done_dialog 2)")
    (action_tile "btn_ss"   "(setq g_blk (get_tile \"eb_blk\")) (done_dialog 3)")
    (action_tile "accept"   "(setq g_blk (get_tile \"eb_blk\") g_scl_min (get_tile \"eb_scl_min\") g_scl_max (get_tile \"eb_scl_max\")
                                   g_rot_fix (get_tile \"eb_rot_fix\") g_ran_scl (get_tile \"tg_ran_scl\") g_ran_rot (get_tile \"tg_ran_rot\")
                                   g_flat (get_tile \"tg_flat\") g_lay (get_tile \"tg_lay\") g_del (get_tile \"tg_del\")) (done_dialog 1)")
    (action_tile "cancel"   "(done_dialog 0)")
    (setq action (start_dialog))
    (if (= action 2) (if (and (setq ent (entsel)) (= (cdr (assoc 0 (entget (car ent)))) "INSERT")) (setq g_blk (cdr (assoc 2 (entget (car ent)))))))
    (if (= action 3) (setq ss (ssget '((0 . "POINT")))))
  )

  ;; 3. التنفيذ
  (if (and (= action 1) (/= g_blk "") ss)
    (progn
      (setvar "CMDECHO" 0) (command "._undo" "_begin")
      (repeat (setq i (sslength ss))
        (setq ent (ssname ss (setq i (1- i)))
              data (entget ent)
              pt (cdr (assoc 10 data))
              lay (cdr (assoc 8 data)))
        
        (if (= g_flat "1") (setq pt (list (car pt) (cadr pt) 0.0)))
        (if (= g_lay "1") (setvar "CLAYER" lay))
        
        ;; حساب المقياس العشوائي
        (setq cur_scl (if (= g_ran_scl "1") 
                         (+ (distof g_scl_min) (* (my-rand) (- (distof g_scl_max) (distof g_scl_min))))
                         (distof g_scl_min)))
        
        ;; حساب الدوران العشوائي
        (setq cur_rot (if (= g_ran_rot "1") (* (my-rand) 360.0) (distof g_rot_fix)))

        (if (tblsearch "BLOCK" g_blk)
          (progn
            (command "-insert" g_blk pt cur_scl cur_scl cur_rot)
            (if (= g_del "1") (entdel ent))
          )
        )
      )
      (command "._undo" "_end") (setvar "CMDECHO" 1)
      (princ (strcat "\nتم استبدال " (itoa (sslength ss)) " نقطة بنجاح."))
    )
  )
  (unload_dialog dcl_id) (vl-file-delete dcl_file) (princ)
)