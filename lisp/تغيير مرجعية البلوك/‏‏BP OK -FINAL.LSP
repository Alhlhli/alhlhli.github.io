;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: BP
;;; الملف الأصلي: ‏‏BP OK -FINAL.LSP
(defun c:BP (/ *error* dcl_id choice ss ent obj bname minpt maxpt newp oldp doc f temp_dcl)
    (vl-load-com)
    (setq doc (vla-get-activedocument (vlax-get-acad-object)))
    (vla-startundomark doc)

    (defun *error* (msg)
        (if (and dcl_id (< 0 dcl_id)) (unload_dialog dcl_id))
        (vla-endundomark doc)
        (if (and msg (not (wcmatch (strcase msg t) "*break*,*cancel*,*exit*")))
            (princ (strcat "\nخطأ: " msg)))
        (princ)
    )

    ;; --- واجهة DCL ---
    (setq temp_dcl (vl-filename-mktemp "BP_UI.dcl"))
    (setq f (open temp_dcl "w"))
    (mapcar '(lambda (x) (write-line x f))
        '("bp_dialog : dialog { label = \"تعديل نقطة الأصل (شامل الزوايا) - م/ عامر\"; "
          " : boxed_column { label = \"النمط\"; "
          "   : radio_button { label = \"1. التقاط نقطة يدوياً\"; key = \"manual\"; value = \"1\"; }"
          "   : radio_button { label = \"2. مركز الحدود (Center)\"; key = \"center\"; } } "
          " : boxed_column { label = \"3. محاذاة سريعة (9 أوضاع)\"; "
          "   : row { : button {label=\"أعلى-يسار\"; key=\"tl\";} : button {label=\"أعلى-وسط\"; key=\"tc\";} : button {label=\"أعلى-يمين\"; key=\"tr\";} }"
          "   : row { : button {label=\"وسط-يسار\"; key=\"ml\";} : button {label=\"المركز (وسط)\"; key=\"mc\";} : button {label=\"وسط-يمين\"; key=\"mr\";} }"
          "   : row { : button {label=\"أسفل-يسار\"; key=\"bl\";} : button {label=\"أسفل-وسط\"; key=\"bc\";} : button {label=\"أسفل-يمين\"; key=\"br\";} }"
          " } spacer_1; ok_cancel; }"))
    (close f)

    (if (setq ss (ssget ":S" '((0 . "INSERT"))))
        (progn
            (setq ent (ssname ss 0)
                  obj (vlax-ename->vla-object ent)
                  bname (vla-get-name obj))

            (setq dcl_id (load_dialog temp_dcl))
            (if (not (new_dialog "bp_dialog" dcl_id)) (exit))
            (setq choice "manual")
            (action_tile "manual" "(setq choice \"manual\")")
            (action_tile "center" "(setq choice \"center\")")
            (foreach key '("tl" "tc" "tr" "ml" "mc" "mr" "bl" "bc" "br")
                (action_tile key (strcat "(setq choice \"" key "\") (done_dialog 1)")))

            (if (= (start_dialog) 1)
                (progn
                    (vla-getboundingbox obj 'minpt 'maxpt)
                    (setq minpt (vlax-safearray->list minpt)
                          maxpt (vlax-safearray->list maxpt))

                    (setq newp
                        (cond
                            ((equal choice "manual") (getpoint "\nاختر النقطة الجديدة للبلوك: "))
                            ((member choice '("center" "mc")) (mapcar '(lambda (a b) (/ (+ a b) 2.0)) minpt maxpt))
                            ((equal choice "tl") (list (car minpt) (cadr maxpt) (caddr minpt)))
                            ((equal choice "tc") (list (/ (+ (car minpt) (car maxpt)) 2.0) (cadr maxpt) (caddr minpt)))
                            ((equal choice "tr") (list (car maxpt) (cadr maxpt) (caddr minpt)))
                            ((equal choice "ml") (list (car minpt) (/ (+ (cadr minpt) (cadr maxpt)) 2.0) (caddr minpt)))
                            ((equal choice "mr") (list (car maxpt) (/ (+ (cadr minpt) (cadr maxpt)) 2.0) (caddr minpt)))
                            ((equal choice "bl") (list (car minpt) (cadr minpt) (caddr minpt)))
                            ((equal choice "bc") (list (/ (+ (car minpt) (car maxpt)) 2.0) (cadr minpt) (caddr minpt)))
                            ((equal choice "br") (list (car maxpt) (cadr minpt) (caddr minpt)))))

                    (if newp
                        (progn
                            (setq oldp (vlax-get obj 'InsertionPoint))
                            ;; 1. حساب "المتجه المحلي" (Local Vector) داخل تعريف البلوك
                            (setq local_vec (LM:WCS-to-Local ent oldp newp))
                            
                            ;; 2. تحريك جميع النسخ في الرسم كلٌ حسب زاويته ومقاسه
                            (if (setq all (ssget "_X" (list '(0 . "INSERT") (cons 2 bname))))
                                (repeat (setq i (sslength all))
                                    (setq o_ent (ssname all (setq i (1- i)))
                                          o_obj (vlax-ename->vla-object o_ent))
                                    ;; حساب الإزاحة العالمية الخاصة بهذا البلوك تحديداً
                                    (setq shift_vec (LM:Local-to-WCS o_ent local_vec))
                                    (vla-move o_obj (vlax-3d-point '(0 0 0)) (vlax-3d-point shift_vec))))

                            ;; 3. تحريك محتويات البلوك داخلياً
                            (vlax-for sub (vla-item (vla-get-blocks doc) bname)
                                (vla-move sub (vlax-3d-point local_vec) (vlax-3d-point '(0 0 0))))
                            
                            (princ (strcat "\nتم التحديث. جميع نسخ [" bname "] ثابتة الآن."))))))
            (unload_dialog dcl_id)))
    (if (findfile temp_dcl) (vl-file-delete temp_dcl))
    (vla-regen doc acallviewports)
    (princ)
)

;; --- دوال رياضية متقدمة للمصفوفات (Matrix Math) ---

;; تحويل الإزاحة من WCS إلى إحداثيات البلوك الداخلية (OCS)
(defun LM:WCS-to-Local ( ent p1 p2 / ang mat )
    (setq ang (-(cdr (assoc 50 (entget ent))))
          mat (list (list (cos ang) (-(sin ang)) 0.0) (list (sin ang) (cos ang) 0.0) '(0.0 0.0 1.0))
          vec (mapcar '- p2 p1)
          scl (list (cdr (assoc 41 (entget ent))) (cdr (assoc 42 (entget ent))) (cdr (assoc 43 (entget ent)))))
    (mapcar '/ (mapcar '(lambda ( r ) (apply '+ (mapcar '* r vec))) mat) scl)
)

;; تحويل الإزاحة المحلية إلى إزاحة عالمية (WCS) لكل نسخة بناءً على دورانها وسكيلها
(defun LM:Local-to-WCS ( ent lvec / ang mat scl )
    (setq ang (cdr (assoc 50 (entget ent)))
          scl (list (cdr (assoc 41 (entget ent))) (cdr (assoc 42 (entget ent))) (cdr (assoc 43 (entget ent))))
          lvec (mapcar '* lvec scl)
          mat (list (list (cos ang) (-(sin ang)) 0.0) (list (sin ang) (cos ang) 0.0) '(0.0 0.0 1.0)))
    (mapcar '(lambda ( r ) (apply '+ (mapcar '* r lvec))) mat)
)
(princ "\n. اكتب BP للبدء.") (princ)