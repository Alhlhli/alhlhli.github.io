;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: IXY
;;; الملف الأصلي: ‏‏ImportXY - نسخة (16).LSP
(defun c:ImportXY+ ( / *error* dcl_id fn f result h lay prefix num raw_data parsed_list
                       temp_file dlg_loaded acad_ver use_z_coords clip-data
                       old_cmdecho old_osmode old_clayer old_attdia old_attreq)

  ;; ============================================
  ;; دالة معالجة الأخطاء
  ;; ============================================
  (defun *error* (msg)
    (setq *error* nil)
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (if old_osmode (setvar "OSMODE" old_osmode))
    (if old_attdia (setvar "ATTDIA" old_attdia))
    (if old_attreq (setvar "ATTREQ" old_attreq))
    (if dlg_loaded (unload_dialog dcl_id))
    (if (and temp_file (findfile temp_file)) (vl-file-delete temp_file))
    (if msg (princ (strcat "\nخطأ: " msg)))
    (princ)
  )

  ;; ============================================
  ;; دالة بديلة للتحقق من NaN (للإصدارات القديمة)
  ;; ============================================
  (defun IsValidNumber (n)
    (and (numberp n)
         (/= n 1.7e308)    ;; +Infinity
         (/= n -1.7e308)   ;; -Infinity
         (= n n))          ;; NaN != NaN
  )

  ;; ============================================
  ;; إعدادات أولية
  ;; ============================================
  (setq old_cmdecho (getvar "CMDECHO")
        old_osmode  (getvar "OSMODE")
        old_clayer  (getvar "CLAYER")
        old_attdia  (getvar "ATTDIA")
        old_attreq  (getvar "ATTREQ"))
  
  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  (setvar "ATTDIA" 0)
  (setvar "ATTREQ" 0)
  (vl-load-com)

  ;; ============================================
  ;; دالة قراءة الحافظة
  ;; ============================================
  (defun GetClipboardData ( / htmlfile result)
    (setq result nil)
    (vl-catch-all-apply
      '(lambda ()
         (setq htmlfile (vlax-create-object "htmlfile"))
         (setq result (vlax-invoke htmlfile "ParentWindow" "ClipboardData" "GetData" "text"))
         (vlax-release-object htmlfile)
       )
    )
    result
  )

  ;; ============================================
  ;; إنشاء ملف DCL
  ;; ============================================
  (setq temp_file (vl-filename-mktemp "import_xy_v3.dcl"))
  (setq f (open temp_file "w"))
  
  (write-line "import_dlg_v3 : dialog {" f)
  (write-line "  label = \"استيراد النقاط المتقدم - V3.0\";" f)
  (write-line "  initial_focus = \"eb_data\";" f)
  (write-line "  spacer;" f)
  (write-line "  : row {" f)
  (write-line "    : column {" f)
  (write-line "      width = 48;" f)
  (write-line "      : boxed_column {" f)
  (write-line "        label = \"⚙️ إعدادات الرسم\";" f)
  (write-line "        alignment = centered;" f)
  (write-line "        : row {" f)
  (write-line "          : edit_box {" f)
  (write-line "            label = \"رقم البداية:\";" f)
  (write-line "            key = \"eb_num\";" f)
  (write-line "            edit_width = 10;" f)
  (write-line "            value = \"1\";" f)
  (write-line "          }" f)
  (write-line "          : edit_box {" f)
  (write-line "            label = \"البادئة:\";" f)
  (write-line "            key = \"eb_pre\";" f)
  (write-line "            edit_width = 10;" f)
  (write-line "            value = \"P\";" f)
  (write-line "          }" f)
  (write-line "        }" f)
  (write-line "        : row {" f)
  (write-line "          : edit_box {" f)
  (write-line "            label = \"ارتفاع النص:\";" f)
  (write-line "            key = \"eb_h\";" f)
  (write-line "            edit_width = 12;" f)
  (write-line "            value = \"2.5\";" f)
  (write-line "          }" f)
  (write-line "          : edit_box {" f)
  (write-line "            label = \"اسم الطبقة:\";" f)
  (write-line "            key = \"eb_lay\";" f)
  (write-line "            edit_width = 12;" f)
  (write-line "            value = \"IMPORTED-POINTS\";" f)
  (write-line "            multi_line = true;" f)
  (write-line "            height = 2;" f)
  (write-line "          }" f)
  (write-line "        }" f)
  (write-line "        : toggle {" f)
  (write-line "          label = \"استخدام إحداثيات Z (3D)\";" f)
  (write-line "          key = \"tg_z\";" f)
  (write-line "          value = \"1\";" f)
  (write-line "        }" f)
  (write-line "      }" f)
  (write-line "      : boxed_column {" f)
  (write-line "        label = \"📋 1. أدخل أو الصق البيانات\";" f)
  (write-line "        : row {" f)
  (write-line "          alignment = centered;" f)
  (write-line "          : button {" f)
  (write-line "            label = \"📥 لصق من الحافظة\";" f)
  (write-line "            key = \"btn_paste\";" f)
  (write-line "            width = 20;" f)
  (write-line "            is_bold = true;" f)
  (write-line "          }" f)
  (write-line "          : button {" f)
  (write-line "            label = \"🗑️ مسح\";" f)
  (write-line "            key = \"btn_clear\";" f)
  (write-line "            width = 12;" f)
  (write-line "          }" f)
  (write-line "        }" f)
  (write-line "        : edit_box {" f)
  (write-line "          key = \"eb_data\";" f)
  (write-line "          width = 48;" f)
  (write-line "          height = 15;" f)
  (write-line "          multi_line = true;" f)
  (write-line "          scrollbar = true;" f)
  (write-line "          allow_accept = false;" f)
  (write-line "          fixed_width_font = true;" f)
  (write-line "        }" f)
  (write-line "        : text {" f)
  (write-line "          key = \"txt_hint\";" f)
  (write-line "          label = \"تلميح: يمكنك لصق مباشرة بـ Ctrl+V أو استخدام الزر\";" f)
  (write-line "          alignment = centered;" f)
  (write-line "        }" f)
  (write-line "        : button {" f)
  (write-line "          label = \"🔍 تحليل البيانات\";" f)
  (write-line "          key = \"btn_analyze\";" f)
  (write-line "          is_default = true;" f)
  (write-line "          width = 25;" f)
  (write-line "        }" f)
  (write-line "      }" f)
  (write-line "    }" f)
  (write-line "    : column {" f)
  (write-line "      width = 52;" f)
  (write-line "      : boxed_column {" f)
  (write-line "        label = \"👁️ 2. معاينة البيانات\";" f)
  (write-line "        : list_box {" f)
  (write-line "          key = \"lb_preview\";" f)
  (write-line "          width = 52;" f)
  (write-line "          height = 22;" f)
  (write-line "          multiple_select = false;" f)
  (write-line "          fixed_width_font = true;" f)
  (write-line "        }" f)
  (write-line "        : text {" f)
  (write-line "          key = \"txt_info\";" f)
  (write-line "          label = \"الحالة: في انتظار البيانات...\";" f)
  (write-line "          alignment = centered;" f)
  (write-line "        }" f)
  (write-line "        : text {" f)
  (write-line "          key = \"txt_stats\";" f)
  (write-line "          label = \"\";" f)
  (write-line "          alignment = centered;" f)
  (write-line "        }" f)
  (write-line "      }" f)
  (write-line "    }" f)
  (write-line "  }" f)
  (write-line "  spacer;" f)
  (write-line "  : row {" f)
  (write-line "    alignment = centered;" f)
  (write-line "    fixed_width = true;" f)
  (write-line "    : button {" f)
  (write-line "      label = \"✓ رسم النقاط\";" f)
  (write-line "      key = \"accept\";" f)
  (write-line "      width = 18;" f)
  (write-line "      is_enabled = false;" f)
  (write-line "    }" f)
  (write-line "    : button {" f)
  (write-line "      label = \"📊 إنشاء تقرير\";" f)
  (write-line "      key = \"btn_report\";" f)
  (write-line "      width = 18;" f)
  (write-line "      is_enabled = false;" f)
  (write-line "    }" f)
  (write-line "    : button {" f)
  (write-line "      label = \"✗ إلغاء\";" f)
  (write-line "      key = \"cancel\";" f)
  (write-line "      width = 15;" f)
  (write-line "      is_cancel = true;" f)
  (write-line "    }" f)
  (write-line "  }" f)
  (write-line "}" f)
  
  (close f)

  ;; ============================================
  ;; دالة التحليل
  ;; ============================================
  (defun parse-advanced (str use-z / regex matches res pts i step 
                              x y z num-count cleaned-str)
    
    (setq cleaned-str (vl-string-translate "،" "," str))
    (setq cleaned-str (vl-string-translate "\t" " " cleaned-str))
    (setq cleaned-str (vl-string-subst " " "  " cleaned-str))
    
    ;; Regex
    (setq regex (vlax-create-object "VBScript.RegExp"))
    (vlax-put-property regex "Global" :vlax-true)
    (vlax-put-property regex "IgnoreCase" :vlax-true)
    (vlax-put-property regex "Pattern" "[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?")
    
    (setq matches (vlax-invoke regex "Execute" cleaned-str))
    (vlax-for m matches 
      (setq res (cons (atof (vlax-get-property m "Value")) res))
    )
    (vlax-release-object regex)
    
    (setq res (reverse res)
          pts nil
          i 0
          step (if (= use-z "1") 3 2)
          num-count 0)
    
    ;; تحليل مع التحقق البديل من NaN
    (while (>= (- (length res) i) step)
      (setq x (nth i res)
            y (nth (1+ i) res)
            z (if (= step 3) (nth (+ i 2) res) 0.0))
      
      ;; استخدام الدالة البديلة IsValidNumber
      (if (and (IsValidNumber x) (IsValidNumber y)
               (< (abs x) 1e15) (< (abs y) 1e15))
        (progn
          (setq pts (cons (list x y z) pts))
          (setq num-count (1+ num-count))
        )
      )
      (setq i (+ i step))
    )
    
    (list (reverse pts) num-count)
  )

  ;; ============================================
  ;; دالة إنشاء الطبقة
  ;; ============================================
  (defun create-layer-advanced (layname / laycolor clean-name)
    (setq clean-name (vl-string-translate "\n" "" layname))
    (setq clean-name (vl-string-translate "\r" "" clean-name))
    (setq clean-name (vl-string-trim " " clean-name))
    
    (setq laycolor (1+ (rem (atoi (substr (vl-princ-to-string clean-name) 2 4)) 255)))
    (if (> laycolor 255) (setq laycolor 1))
    
    (if (not (tblsearch "LAYER" clean-name))
      (entmake (list 
        '(0 . "LAYER")
        '(100 . "AcDbSymbolTableRecord")
        '(100 . "AcDbLayerTableRecord")
        (cons 2 clean-name)
        '(70 . 0)
        (cons 62 laycolor)
        '(6 . "Continuous")
      ))
    )
    (setvar "CLAYER" clean-name)
    clean-name
  )

  ;; ============================================
  ;; دالة رسم النقطة
  ;; ============================================
  (defun draw-point-annotated (pt prefix num h lay / pt-ent txt-ent ins-pt clean-prefix)
    (setq clean-prefix (vl-string-translate "\n" "" prefix))
    (setq clean-prefix (vl-string-translate "\r" "" clean-prefix))
    
    (setq pt-ent (entmake (list 
      '(0 . "POINT")
      (cons 10 pt)
      (cons 8 lay)
      '(100 . "AcDbEntity")
      '(100 . "AcDbPoint")
    )))
    
    (setq ins-pt (list (+ (car pt) (* h 0.1)) (+ (cadr pt) (* h 0.1)) (caddr pt)))
    (setq txt-ent (entmake (list
      '(0 . "TEXT")
      '(100 . "AcDbEntity")
      '(100 . "AcDbText")
      (cons 10 ins-pt)
      (cons 40 h)
      (cons 1 (strcat clean-prefix (itoa num)))
      (cons 8 lay)
      '(50 . 0.0)
      '(72 . 0)
      (cons 11 ins-pt)
      '(100 . "AcDbText")
      '(73 . 0)
    )))
    
    (if (and pt-ent txt-ent) T nil)
  )

  ;; ============================================
  ;; تحميل الواجهة
  ;; ============================================
  (setq dcl_id (load_dialog temp_file))
  (if (< dcl_id 0)
    (*error* "فشل تحميل ملف الحوار!")
  )
  
  (setq dlg_loaded T)
  
  (if (not (new_dialog "import_dlg_v3" dcl_id))
    (*error* "فشل إنشاء الحوار!")
  )

  (set_tile "eb_num" "1")
  (set_tile "eb_pre" "P")
  (set_tile "eb_h" "2.5")
  (set_tile "eb_lay" "IMPORTED-POINTS")
  (set_tile "tg_z" "1")

  ;; ============================================
  ;; دوال الأحداث
  ;; ============================================
  (action_tile "btn_paste" "(paste-callback)")
  
  (defun paste-callback ()
    (setq clip-data (GetClipboardData))
    (if (and clip-data (/= clip-data ""))
      (progn
        (setq clip-data (vl-string-translate "\t" " " clip-data))
        (set_tile "eb_data" clip-data)
        (set_tile "txt_hint" "✅ تم اللصق! اضغط تحليل أو Ctrl+A ثم Enter")
        (mode_tile "btn_analyze" 2)
      )
      (progn
        (set_tile "txt_hint" "❌ الحافظة فارغة أو لا يمكن الوصول إليها")
        (mode_tile "eb_data" 2)
      )
    )
  )

  (action_tile "btn_clear" "(clear-callback)")
  
  (defun clear-callback ()
    (set_tile "eb_data" "")
    (set_tile "txt_hint" "تم المسح. يمكنك لصق بيانات جديدة")
    (start_list "lb_preview")
    (end_list)
    (set_tile "txt_info" "الحالة: في انتظار البيانات...")
    (set_tile "txt_stats" "")
    (set_tile "accept" "0")
    (set_tile "btn_report" "0")
    (mode_tile "eb_data" 2)
  )

  (action_tile "btn_analyze" "(analyze-callback)")
  
  (defun analyze-callback ()
    (setq raw_data (get_tile "eb_data"))
    (setq use_z_coords (get_tile "tg_z"))
    
    (if (or (null raw_data) (= raw_data ""))
      (progn
        (set_tile "txt_info" "⚠️ يرجى إدخال البيانات أولاً!")
        (set_tile "txt_hint" "استخدم زر اللصق أو Ctrl+V للصق البيانات")
        (mode_tile "eb_data" 2)
      )
      (progn
        (setq result-parse (parse-advanced raw_data use_z_coords))
        (setq parsed_list (car result-parse))
        (setq count (cadr result-parse))
        
        (if (null parsed_list)
          (progn
            (set_tile "txt_info" "❌ لم يتم العثور على إحداثيات صالحة!")
            (set_tile "txt_hint" "تأكد من صيغة البيانات: X Y [Z] في كل سطر")
            (start_list "lb_preview")
            (end_list)
            (set_tile "accept" "0")
            (set_tile "btn_report" "0")
          )
          (progn
            (start_list "lb_preview")
            (setq i 1)
            (foreach pt parsed_list
              (add_list (strcat 
                (if (< i 10) "  " (if (< i 100) " " ""))
                (itoa i) 
                ":  X=" (rtos (car pt) 2 4)
                "  Y=" (rtos (cadr pt) 2 4)
                (if (= use_z_coords "1") (strcat "  Z=" (rtos (caddr pt) 2 3)) "")
              ))
              (setq i (1+ i))
            )
            (end_list)
            
            (set_tile "txt_info" (strcat "✅ تم العثور على " (itoa count) " نقطة"))
            
            (setq x-range (mapcar 'car parsed_list))
            (setq y-range (mapcar 'cadr parsed_list))
            (setq x-min (apply 'min x-range)
                  x-max (apply 'max x-range)
                  y-min (apply 'min y-range)
                  y-max (apply 'max y-range))
            
            (set_tile "txt_stats" (strcat 
              "نطاق X: " (rtos x-min 2 2) " إلى " (rtos x-max 2 2)
              " | Y: " (rtos y-min 2 2) " إلى " (rtos y-max 2 2)
            ))
            
            (set_tile "accept" "1")
            (set_tile "btn_report" "1")
            (setq dlg_data parsed_list)
            (set_tile "txt_hint" "جاهز للرسم! اضغط 'رسم النقاط'")
          )
        )
      )
    )
  )

  (action_tile "btn_report" "(report-callback)")
  
  (defun report-callback ()
    (if dlg_data
      (progn
        (setq rpt_file (vl-filename-mktemp "points_report_*.txt"))
        (setq rpt (open rpt_file "w"))
        (write-line "========================================" rpt)
        (write-line "    تقرير نقاط الاستيراد" rpt)
        (write-line "========================================" rpt)
        (write-line "" rpt)
        (write-line (strcat "التاريخ: " (rtos (getvar "CDATE") 2 0)) rpt)
        (write-line (strcat "عدد النقاط: " (itoa (length dlg_data))) rpt)
        (write-line "" rpt)
        (write-line "----------------------------------------" rpt)
        (write-line "رقم        X              Y              Z" rpt)
        (write-line "----------------------------------------" rpt)
        
        (setq i 1)
        (foreach pt dlg_data
          (write-line (strcat 
            (itoa i) 
            (repeat (- 10 (strlen (itoa i))) " ")
            (rtos (car pt) 2 6)
            "    "
            (rtos (cadr pt) 2 6)
            "    "
            (rtos (caddr pt) 2 6)
          ) rpt)
          (setq i (1+ i))
        )
        
        (write-line "----------------------------------------" rpt)
        (close rpt)
        
        (startapp "notepad.exe" rpt_file)
        (set_tile "txt_hint" (strcat "تم فتح التقرير: " rpt_file))
      )
    )
  )

  (action_tile "accept" "(setq num (atoi (get_tile \"eb_num\")) \
                          prefix (get_tile \"eb_pre\") \
                          h (atof (get_tile \"eb_h\")) \
                          lay (get_tile \"eb_lay\") \
                          result 1) \
                         (done_dialog 1)")

  (action_tile "cancel" "(setq result 0)(done_dialog 0)")

  (setq result (start_dialog))
  
  (unload_dialog dcl_id)
  (setq dlg_loaded nil)
  (if (findfile temp_file) (vl-file-delete temp_file))

  ;; ============================================
  ;; تنفيذ الرسم
  ;; ============================================
  (if (and (= result 1) dlg_data (> (length dlg_data) 0))
    (progn
      (create-layer-advanced lay)
      
      (setq total (length dlg_data)
            success 0
            failed 0)
      
      (princ (strcat "\nجاري رسم " (itoa total) " نقطة..."))
      
      (foreach pt dlg_data
        (if (draw-point-annotated pt prefix num h lay)
          (setq success (1+ success))
          (setq failed (1+ failed))
        )
        (setq num (1+ num))
        
        (if (= (rem success 10) 0)
          (princ (strcat "\rتم: " (itoa success) "/" (itoa total)))
        )
      )
      
      (setvar "CMDECHO" old_cmdecho)
      (setvar "OSMODE" old_osmode)
      (setvar "CLAYER" old_clayer)
      (setvar "ATTDIA" old_attdia)
      (setvar "ATTREQ" old_attreq)
      
      (princ (strcat "\n✅ اكتمل: " (itoa success) " نقطة مرسومة"))
      (if (> failed 0) (princ (strcat " | ❌ فشل: " (itoa failed))))
      
      (command "_.zoom" "_e")
      (princ "\n")
    )
    (if (= result 1) 
      (alert "لا توجد بيانات صالحة للرسم!\nيرجى التحليل أولاً.")
    )
  )
  
  (setq temp_file nil dlg_data nil parsed_list nil clip-data nil)
  (princ)
)

;; ============================================
;; أمر تصدير النقاط
;; ============================================
(defun c:ExportXY ( / ss i pt-data fname f)
  (vl-load-com)
  (setq ss (ssget '((0 . "POINT"))))
  (if (null ss)
    (princ "\nلم يتم اختيار أي نقاط!")
    (progn
      (setq fname (getfiled "حفظ الإحداثيات" "" "txt;csv" 1))
      (if fname
        (progn
          (setq f (open fname "w"))
          (write-line "X,Y,Z" f)
          (setq i 0)
          (repeat (sslength ss)
            (setq ent (ssname ss i))
            (setq pt (cdr (assoc 10 (entget ent))))
            (write-line (strcat (rtos (car pt) 2 8) "," 
                               (rtos (cadr pt) 2 8) "," 
                               (rtos (caddr pt) 2 8)) f)
            (setq i (1+ i))
          )
          (close f)
          (princ (strcat "\nتم تصدير " (itoa i) " نقطة إلى:\n" fname))
        )
      )
    )
  )
  (princ)
)

(princ "\n========================================")
(princ "\nأوامر استيراد/تصدير النقاط - V3.0")
(princ "\n========================================")
(princ "\nImportXY+  - استيراد نقاط مع واجهة متقدمة")
(princ "\nExportXY   - تصدير النقاط المحددة")
(princ "\n========================================")
(princ "\n")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:IXY () (c:ImportXY+))
