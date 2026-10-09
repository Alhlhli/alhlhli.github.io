;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: SSL
;;; الملف الأصلي: SS_SelectSimilar (1).lsp
;;; ============================================================
;;; SS_SelectSimilar.lsp
;;; تحديد الكيانات المتشابهة داخل منطقة - مع مربع حوار DCL
;;; الإصدار 3.0 - مع إصلاح خطأ TEST-TYPE
;;; ============================================================
;;; الأوامر:
;;;   SS  - الأمر الرئيسي مع مربع حوار رسومي
;;;   SSL - تحديد سريع بالطبقة
;;;   SSB - تحديد بلوكات متشابهة
;;; ============================================================

;;; -------------------------------------------------------
;;; الخطوة 1: إنشاء ملف DCL مؤقت تلقائياً
;;; -------------------------------------------------------
(defun ss:write-dcl (/ dcl-path f)
  (setq dcl-path (strcat (getvar "TEMPPREFIX") "SS_Dialog.dcl"))
  (setq f (open dcl-path "w"))
  (write-line "ss_select_similar : dialog {" f)
  (write-line "  label = \"SS - تحديد المتشابه في منطقة\";" f)
  (write-line "  width = 52;" f)
  (write-line "  : boxed_column {" f)
  (write-line "    label = \"الكيان المرجعي\";" f)
  (write-line "    : row {" f)
  (write-line "      : text { label = \"النوع :\"; width = 10; }" f)
  (write-line "      : text { key = \"ref_type\"; width = 18; label = \"---\"; }" f)
  (write-line "      : text { label = \"الطبقة :\"; width = 10; }" f)
  (write-line "      : text { key = \"ref_layer\"; width = 18; label = \"---\"; }" f)
  (write-line "    }" f)
  (write-line "    : row {" f)
  (write-line "      : text { label = \"البلوك :\"; width = 10; }" f)
  (write-line "      : text { key = \"ref_block\"; width = 40; label = \"\"; }" f)
  (write-line "    }" f)
  (write-line "  }" f)
  (write-line "  spacer_1;" f)
  (write-line "  : boxed_column {" f)
  (write-line "    label = \"معايير التشابه\";" f)
  (write-line "    : row {" f)
  (write-line "      : toggle { key = \"crit_layer\";      label = \"الطبقة\";       value = \"1\"; width = 16; }" f)
  (write-line "      : toggle { key = \"crit_color\";      label = \"اللون\";         value = \"0\"; width = 16; }" f)
  (write-line "      : toggle { key = \"crit_linetype\";   label = \"نوع الخط\";     value = \"0\"; width = 16; }" f)
  (write-line "    }" f)
  (write-line "    : row {" f)
  (write-line "      : toggle { key = \"crit_lineweight\"; label = \"وزن الخط\";     value = \"0\"; width = 16; }" f)
  (write-line "      : toggle { key = \"crit_textheight\"; label = \"ارتفاع النص\";  value = \"0\"; width = 16; }" f)
  (write-line "      : toggle { key = \"crit_textstyle\";  label = \"نمط النص\";     value = \"0\"; width = 16; }" f)
  (write-line "    }" f)
  (write-line "    spacer_1;" f)
  (write-line "    : row {" f)
  (write-line "      : button { key = \"preset_1\"; label = \"طبقة فقط\";             width = 16; }" f)
  (write-line "      : button { key = \"preset_2\"; label = \"لون فقط\";              width = 16; }" f)
  (write-line "      : button { key = \"preset_3\"; label = \"طبقة + لون + خط\";     width = 18; }" f)
  (write-line "    }" f)
  (write-line "    : row {" f)
  (write-line "      : button { key = \"preset_4\"; label = \"نوع فقط (بلا شروط)\"; width = 24; }" f)
  (write-line "      : button { key = \"preset_5\"; label = \"كل المعايير\";          width = 24; }" f)
  (write-line "    }" f)
  (write-line "  }" f)
  (write-line "  spacer_1;" f)
  (write-line "  : boxed_radio_column {" f)
  (write-line "    label = \"منطقة البحث\";" f)
  (write-line "    key = \"area_mode_group\";" f)
  (write-line "    : radio_button { key = \"area_1\"; label = \"نافذة مستطيلة   (Window)\";          value = \"1\"; }" f)
  (write-line "    : radio_button { key = \"area_2\"; label = \"مضلع تقاطع     (Crossing Polygon)\"; value = \"0\"; }" f)
  (write-line "    : radio_button { key = \"area_3\"; label = \"نصف قطر دائرة  (Radius)\";           value = \"0\"; }" f)
  (write-line "    : radio_button { key = \"area_4\"; label = \"الرسم كاملاً   (Entire Drawing)\";   value = \"0\"; }" f)
  (write-line "  }" f)
  (write-line "  spacer_1;" f)
  (write-line "  : row {" f)
  (write-line "    : button { key = \"accept\"; label = \"  تحديد المتشابه  \"; is_default = true; width = 24; }" f)
  (write-line "    spacer_1;" f)
  (write-line "    : button { key = \"cancel\"; label = \"  الغاء  \"; is_cancel = true; width = 14; }" f)
  (write-line "  }" f)
  (write-line "  : text { key = \"status_msg\"; label = \" \"; width = 52; }" f)
  (write-line "}" f)
  (close f)
  dcl-path
)

;;; -------------------------------------------------------
;;; الخطوة 2: دالة الضبط المسبق (Presets)
;;; -------------------------------------------------------
(defun ss:set-preset (pnum etype)
  (cond
    ((= pnum 1)
      (set_tile "crit_layer" "1") (set_tile "crit_color" "0")
      (set_tile "crit_linetype" "0") (set_tile "crit_lineweight" "0")
      (set_tile "crit_textheight" "0") (set_tile "crit_textstyle" "0")
    )
    ((= pnum 2)
      (set_tile "crit_layer" "0") (set_tile "crit_color" "1")
      (set_tile "crit_linetype" "0") (set_tile "crit_lineweight" "0")
      (set_tile "crit_textheight" "0") (set_tile "crit_textstyle" "0")
    )
    ((= pnum 3)
      (set_tile "crit_layer" "1") (set_tile "crit_color" "1")
      (set_tile "crit_linetype" "1") (set_tile "crit_lineweight" "0")
      (set_tile "crit_textheight" "0") (set_tile "crit_textstyle" "0")
    )
    ((= pnum 4)
      (set_tile "crit_layer" "0") (set_tile "crit_color" "0")
      (set_tile "crit_linetype" "0") (set_tile "crit_lineweight" "0")
      (set_tile "crit_textheight" "0") (set_tile "crit_textstyle" "0")
    )
    ((= pnum 5)
      (set_tile "crit_layer" "1") (set_tile "crit_color" "1")
      (set_tile "crit_linetype" "1") (set_tile "crit_lineweight" "1")
      (if (member etype '("TEXT" "MTEXT" "ATTDEF" "ATTRIB"))
        (progn (set_tile "crit_textheight" "1") (set_tile "crit_textstyle" "1"))
        (progn (set_tile "crit_textheight" "0") (set_tile "crit_textstyle" "0"))
      )
    )
  )
)

;;; -------------------------------------------------------
;;; الخطوة 3: دالة المقارنة - مصححة بالكامل
;;; السبب الجذري للخطأ: استخدام متغيرات محلية كأسماء دوال
;;; الحل: استخراج كل القيم مباشرة بـ (cdr (assoc ...))
;;; -------------------------------------------------------
(defun ss:match-p (re te crit / rtype ttype rmatch)
  ;; استخراج النوع مباشرة من قائمة الكيان
  (setq rtype  (cdr (assoc 0 (entget re))))
  (setq ttype  (cdr (assoc 0 (entget te))))
  (setq rmatch T)

  ;; شرط أساسي: تطابق النوع
  (if (/= rtype ttype) (setq rmatch nil))

  ;; للبلوكات: تطابق اسم البلوك
  (if (and rmatch (= rtype "INSERT"))
    (if (/= (cdr (assoc 2 (entget re)))
            (cdr (assoc 2 (entget te))))
      (setq rmatch nil)
    )
  )

  ;; الطبقة
  (if (and rmatch (= (nth 0 crit) 1))
    (if (/= (cdr (assoc 8 (entget re)))
            (cdr (assoc 8 (entget te))))
      (setq rmatch nil)
    )
  )

  ;; اللون
  (if (and rmatch (= (nth 1 crit) 1))
    (if (/= (cdr (assoc 62 (entget re)))
            (cdr (assoc 62 (entget te))))
      (setq rmatch nil)
    )
  )

  ;; نوع الخط
  (if (and rmatch (= (nth 2 crit) 1))
    (if (/= (cdr (assoc 6 (entget re)))
            (cdr (assoc 6 (entget te))))
      (setq rmatch nil)
    )
  )

  ;; وزن الخط
  (if (and rmatch (= (nth 3 crit) 1))
    (if (/= (cdr (assoc 370 (entget re)))
            (cdr (assoc 370 (entget te))))
      (setq rmatch nil)
    )
  )

  ;; ارتفاع النص
  (if (and rmatch (= (nth 4 crit) 1)
           (member rtype '("TEXT" "MTEXT" "ATTDEF" "ATTRIB")))
    (progn
      (setq rh (cdr (assoc 40 (entget re))))
      (setq th (cdr (assoc 40 (entget te))))
      (if (and rh th (/= rh th)) (setq rmatch nil))
    )
  )

  ;; نمط النص
  (if (and rmatch (= (nth 5 crit) 1)
           (member rtype '("TEXT" "MTEXT" "ATTDEF" "ATTRIB")))
    (if (/= (cdr (assoc 7 (entget re)))
            (cdr (assoc 7 (entget te))))
      (setq rmatch nil)
    )
  )

  rmatch
)

;;; -------------------------------------------------------
;;; دالة: تحديد المنطقة بعد إغلاق الحوار
;;; -------------------------------------------------------
(defun ss:pick-area (amode / p1 p2 cx r)
  (cond
    ((= amode 1)
      (princ "\n>> ركن اول: ")
      (setq p1 (getpoint))
      (if p1
        (progn
          (princ "\n>> الركن المقابل: ")
          (setq p2 (getcorner p1))
          (if p2 (ssget "C" p1 p2) nil)
        )
        nil
      )
    )
    ((= amode 2)
      (princ "\n>> نقاط المضلع (Enter للإنهاء): ")
      (ssget "CP")
    )
    ((= amode 3)
      (princ "\n>> المركز: ")
      (setq cx (getpoint))
      (if cx
        (progn
          (princ "\n>> نصف القطر: ")
          (setq r (getreal))
          (if (and r (> r 0))
            (ssget "C"
              (list (- (car cx) r) (- (cadr cx) r) 0.0)
              (list (+ (car cx) r) (+ (cadr cx) r) 0.0)
            )
            nil
          )
        )
        nil
      )
    )
    ((= amode 4) (ssget "X"))
    (T
      (princ "\n>> حدد المنطقة: ")
      (ssget)
    )
  )
)

;;; -------------------------------------------------------
;;; الأمر الرئيسي: SS
;;; -------------------------------------------------------
(defun C:SS (/ *error* oe oo dcl-path dcl-id
               ref-ss ref-ent etype elayer eblock
               crit amode rc
               sss rss cnt i tent)

  (setq *error*
    (lambda (m)
      (if (not (member m '("Function cancelled" "quit / exit abort")))
        (princ (strcat "\n** خطأ: " m "\n"))
      )
      (setvar "CMDECHO" oe)
      (setvar "OSMODE"  oo)
      (princ)
    )
  )

  (setq oe (getvar "CMDECHO"))
  (setq oo (getvar "OSMODE"))
  (setvar "CMDECHO" 0)
  (vl-load-com)

  ;; تحديد الكيان المرجعي
  (setq ref-ss (ssget "I"))
  (if (and ref-ss (> (sslength ref-ss) 0))
    (setq ref-ent (ssname ref-ss 0))
    (progn
      (princ "\n>> حدد كيان مرجعي: ")
      (setq ref-ent (car (entsel)))
    )
  )

  (if (not ref-ent)
    (progn
      (princ "\n** لم يتم التحديد. إلغاء.\n")
      (setvar "CMDECHO" oe)
      (setvar "OSMODE"  oo)
      (princ)
    )
    (progn
      (setq etype  (cdr (assoc 0 (entget ref-ent))))
      (setq elayer (cdr (assoc 8 (entget ref-ent))))
      (setq eblock
        (if (= etype "INSERT")
          (cdr (assoc 2 (entget ref-ent)))
          "---"
        )
      )

      ;; تحميل الحوار
      (setq dcl-path (ss:write-dcl))
      (setq dcl-id (load_dialog dcl-path))

      (if (< dcl-id 0)
        (progn
          (princ "\n** تعذّر تحميل مربع الحوار.\n")
          (setvar "CMDECHO" oe)
          (setvar "OSMODE"  oo)
          (princ)
        )
        (progn
          (new_dialog "ss_select_similar" dcl-id)

          ;; عرض معلومات الكيان
          (set_tile "ref_type"  etype)
          (set_tile "ref_layer" elayer)
          (set_tile "ref_block" eblock)

          ;; تعطيل خيارات النص إن لم يكن الكيان نصاً
          (if (not (member etype '("TEXT" "MTEXT" "ATTDEF" "ATTRIB")))
            (progn
              (mode_tile "crit_textheight" 1)
              (mode_tile "crit_textstyle"  1)
            )
          )

          ;; أزرار الاختصارات - نمرر etype كمتغير مباشر
          (action_tile "preset_1" "(ss:set-preset 1 etype)")
          (action_tile "preset_2" "(ss:set-preset 2 etype)")
          (action_tile "preset_3" "(ss:set-preset 3 etype)")
          (action_tile "preset_4" "(ss:set-preset 4 etype)")
          (action_tile "preset_5" "(ss:set-preset 5 etype)")

          ;; زر التنفيذ
          (action_tile "accept"
            (strcat
              "(setq crit (list"
              "  (atoi (get_tile \"crit_layer\"))"
              "  (atoi (get_tile \"crit_color\"))"
              "  (atoi (get_tile \"crit_linetype\"))"
              "  (atoi (get_tile \"crit_lineweight\"))"
              "  (atoi (get_tile \"crit_textheight\"))"
              "  (atoi (get_tile \"crit_textstyle\"))"
              "))"
              "(setq amode"
              "  (cond"
              "    ((= (get_tile \"area_1\") \"1\") 1)"
              "    ((= (get_tile \"area_2\") \"1\") 2)"
              "    ((= (get_tile \"area_3\") \"1\") 3)"
              "    ((= (get_tile \"area_4\") \"1\") 4)"
              "    (T 1)"
              "  )"
              ")"
              "(done_dialog 1)"
            )
          )
          (action_tile "cancel" "(done_dialog 0)")

          (setq rc (start_dialog))
          (unload_dialog dcl-id)

          (if (= rc 1)
            (progn
              (setvar "OSMODE" 0)

              ;; تحديد المنطقة
              (setq sss (ss:pick-area amode))

              (if (not sss)
                (princ "\n** لم يتم تحديد منطقة. إلغاء.\n")
                (progn
                  ;; البحث والمقارنة
                  (setq rss (ssadd))
                  (setq cnt 0)
                  (setq i 0)

                  (while (< i (sslength sss))
                    (setq tent (ssname sss i))
                    (if (and tent (/= tent ref-ent))
                      (if (ss:match-p ref-ent tent crit)
                        (progn
                          (ssadd tent rss)
                          (setq cnt (1+ cnt))
                        )
                      )
                    )
                    (setq i (1+ i))
                  )

                  ;; إضافة المرجعي نفسه
                  (ssadd ref-ent rss)
                  (setq cnt (1+ cnt))

                  (sssetfirst nil rss)
                  (princ (strcat "\n✔ تم تحديد " (itoa cnt) " كيان متشابه.\n"))
                )
              )
            )
            (princ "\n** إلغاء.\n")
          )

          (setvar "CMDECHO" oe)
          (setvar "OSMODE"  oo)
          (princ)
        )
      )
    )
  )
)

;;; -------------------------------------------------------
;;; أمر SSL - سريع بالطبقة
;;; -------------------------------------------------------
(defun C:SSL (/ *error* oe re rt rl sss rss cnt i tent tt tl)
  (setq *error* (lambda (m) (setvar "CMDECHO" oe) (princ)))
  (setq oe (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (setq re (car (entsel "\n>> حدد الكيان المرجعي: ")))
  (if re
    (progn
      (setq rt (cdr (assoc 0 (entget re))))
      (setq rl (cdr (assoc 8 (entget re))))
      (princ (strcat "\n>> [" rt " / " rl "] - حدد المنطقة: "))
      (setq sss (ssget))
      (if sss
        (progn
          (setq rss (ssadd)) (setq cnt 0) (setq i 0)
          (while (< i (sslength sss))
            (setq tent (ssname sss i))
            (setq tt (cdr (assoc 0 (entget tent))))
            (setq tl (cdr (assoc 8 (entget tent))))
            (if (and (= tt rt) (= tl rl))
              (progn (ssadd tent rss) (setq cnt (1+ cnt)))
            )
            (setq i (1+ i))
          )
          (ssadd re rss)
          (sssetfirst nil rss)
          (princ (strcat "\n✔ طبقة [" rl "]: " (itoa cnt) " كيان\n"))
        )
        (princ "\n** لم تحدد منطقة.\n")
      )
    )
    (princ "\n** لم تحدد كيان.\n")
  )
  (setvar "CMDECHO" oe)
  (princ)
)

;;; -------------------------------------------------------
;;; أمر SSB - سريع للبلوكات
;;; -------------------------------------------------------
(defun C:SSB (/ *error* oe re rn sss rss cnt i tent tn tt)
  (setq *error* (lambda (m) (setvar "CMDECHO" oe) (princ)))
  (setq oe (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  (setq re (car (entsel "\n>> حدد البلوك المرجعي: ")))
  (if (and re (= (cdr (assoc 0 (entget re))) "INSERT"))
    (progn
      (setq rn (cdr (assoc 2 (entget re))))
      (princ (strcat "\n>> البلوك [" rn "] - حدد المنطقة: "))
      (setq sss (ssget))
      (if sss
        (progn
          (setq rss (ssadd)) (setq cnt 0) (setq i 0)
          (while (< i (sslength sss))
            (setq tent (ssname sss i))
            (setq tt (cdr (assoc 0 (entget tent))))
            (setq tn (cdr (assoc 2 (entget tent))))
            (if (and (= tt "INSERT") (= tn rn))
              (progn (ssadd tent rss) (setq cnt (1+ cnt)))
            )
            (setq i (1+ i))
          )
          (sssetfirst nil rss)
          (princ (strcat "\n✔ البلوك [" rn "]: " (itoa cnt) " نسخة\n"))
        )
        (princ "\n** لم تحدد منطقة.\n")
      )
    )
    (princ "\n** الكيان ليس بلوكاً.\n")
  )
  (setvar "CMDECHO" oe)
  (princ)
)

;;; -------------------------------------------------------
;;; رسالة التحميل
;;; -------------------------------------------------------
(princ "\n")
(princ "+------------------------------------------------+\n")
(princ "|  SS_SelectSimilar v3.0  -  تم التحميل          |\n")
(princ "+------------------------------------------------+\n")
(princ "|  SS   تحديد متشابه + مربع حوار DCL             |\n")
(princ "|  SSL  تحديد سريع بالطبقة                       |\n")
(princ "|  SSB  تحديد بلوكات متشابهة                     |\n")
(princ "+------------------------------------------------+\n")
(princ)
