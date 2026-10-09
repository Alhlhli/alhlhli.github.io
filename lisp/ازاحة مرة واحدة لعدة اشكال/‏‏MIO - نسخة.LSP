;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: MIO
;;; الملف الأصلي: ‏‏MIO - نسخة.LSP
;;; -------------------------------------------------------------------------
;;; Multi Offset (Inside/Outside) with Color Control
;;; Designed by: Eng. Amer Al-Halhali | Al3mer
;;; -------------------------------------------------------------------------

(defun c:MIO (/ *error* dcl_id fn dcl_code distVal layerOpt inputLayerName dirOpt colorIdx ss i ent obj oldArea newObj newArea param newObjList run_process finalColor)
  (vl-load-com)

  ;;; معالجة الأخطاء
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (if (< 0 dcl_id) (unload_dialog dcl_id))
    (if (and fn (findfile fn)) (vl-file-delete fn))
    (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
    (princ)
  )

  (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))

  ;;; -----------------------------------------------------------------------
  ;;; إنشاء ملف الواجهة (DCL)
  ;;; -----------------------------------------------------------------------
  (setq fn (vl-filename-mktemp "Al3mer_MIO.dcl"))
  (setq dcl_code (open fn "w"))
  
  (write-line "Al3mer_Dialog : dialog {" dcl_code)
  (write-line "  label = \"Multi Offset | Al3mer\";" dcl_code)
  (write-line "  : text { label = \"Designed by: Eng. Amer Al-Halhali (Al3mer)\"; alignment = centered; }" dcl_code)
  (write-line "  spacer_1;" dcl_code)

  ;; قسم المسافة والاتجاه
  (write-line "  : boxed_column {" dcl_code)
  (write-line "    label = \"Settings / الإعدادات\";" dcl_code)
  (write-line "    : edit_box { label = \"Distance / المسافة:\"; key = \"txt_dist\"; edit_width = 10; }" dcl_code)
  (write-line "    : radio_row {" dcl_code)
  (write-line "       label = \"Direction / الاتجاه\";" dcl_code)
  (write-line "       : radio_button { label = \"Inside / للداخل\"; key = \"rb_in\"; }" dcl_code)
  (write-line "       : radio_button { label = \"Outside / للخارج\"; key = \"rb_out\"; }" dcl_code)
  (write-line "    }" dcl_code)
  (write-line "  }" dcl_code)

  ;; قسم اللون
  (write-line "  : boxed_column {" dcl_code)
  (write-line "    label = \"Appearance / المظهر\";" dcl_code)
  (write-line "    : popup_list { label = \"Color / اللون:\"; key = \"pop_color\"; edit_width = 20; list = \"ByLayer\n1 - Red\n2 - Yellow\n3 - Green\n4 - Cyan\n5 - Blue\n6 - Magenta\n7 - White\"; }" dcl_code)
  (write-line "  }" dcl_code)

  ;; قسم الطبقات
  (write-line "  : boxed_radio_column {" dcl_code)
  (write-line "    label = \"Target Layer / الطبقة\";" dcl_code)
  (write-line "    : radio_button { label = \"Source Layer / نفس المصدر\"; key = \"rb_source\"; value = \"1\"; }" dcl_code)
  (write-line "    : radio_button { label = \"Current Layer / الطبقة الحالية\"; key = \"rb_current\"; }" dcl_code)
  (write-line "    : row {" dcl_code)
  (write-line "      : radio_button { label = \"Name / اسم طبقة:\"; key = \"rb_name\"; }" dcl_code)
  (write-line "      : edit_box { key = \"txt_layername\"; edit_width = 15; }" dcl_code)
  (write-line "    }" dcl_code)
  (write-line "  }" dcl_code)

  (write-line "  spacer_1;" dcl_code)
  (write-line "  ok_cancel;" dcl_code)
  (write-line "}" dcl_code)
  (close dcl_code)

  ;;; -----------------------------------------------------------------------
  ;;; تحميل وتشغيل الواجهة
  ;;; -----------------------------------------------------------------------
  (setq dcl_id (load_dialog fn))
  (if (not (new_dialog "Al3mer_Dialog" dcl_id)) (exit))

  ;; القيم الافتراضية
  (if (not *MIO_Dist*) (setq *MIO_Dist* "1.0"))
  (set_tile "txt_dist" *MIO_Dist*)
  
  (if (not *MIO_Dir*) (setq *MIO_Dir* "In"))
  (if (= *MIO_Dir* "In") (set_tile "rb_in" "1") (set_tile "rb_out" "1"))

  (set_tile "pop_color" "0") ; Default to ByLayer

  ;; حفظ المدخلات عند الضغط على OK
  (action_tile "accept" 
    "(setq distVal (atof (get_tile \"txt_dist\")))
     (setq *MIO_Dist* (get_tile \"txt_dist\"))
     (if (= (get_tile \"rb_in\") \"1\") (setq dirOpt \"Inside\") (setq dirOpt \"Outside\"))
     (setq *MIO_Dir* (if (= dirOpt \"Inside\") \"In\" \"Out\"))
     (setq colorIdx (atoi (get_tile \"pop_color\"))) 
     (cond 
       ((= (get_tile \"rb_source\") \"1\") (setq layerOpt \"Source\"))
       ((= (get_tile \"rb_current\") \"1\") (setq layerOpt \"Current\"))
       ((= (get_tile \"rb_name\") \"1\") (setq layerOpt \"Name\"))
     )
     (setq inputLayerName (get_tile \"txt_layername\"))
     (done_dialog 1)"
  )
  (action_tile "cancel" "(done_dialog 0)")

  (setq run_process (start_dialog))
  (unload_dialog dcl_id)
  (vl-file-delete fn)

  ;;; -----------------------------------------------------------------------
  ;;; التنفيذ
  ;;; -----------------------------------------------------------------------
  (if (= run_process 1)
    (progn
      ;; تجهيز اسم الطبقة
      (if (and (= layerOpt "Name") (= inputLayerName "")) (setq inputLayerName "Al3mer_Offset"))
      (if (= layerOpt "Name")
        (if (not (tblsearch "LAYER" inputLayerName)) (command "-layer" "m" inputLayerName ""))
      )

      ;; تحديد لون الأوتوكاد (ACI) بناءً على القائمة
      ;; القائمة: 0=ByLayer, 1=Red(1), 2=Yellow(2)... etc.
      ;; إذا كان 0 سنجعله 256 (ByLayer)
      (setq finalColor (if (= colorIdx 0) 256 colorIdx))

      (princ "\nSelect Closed Polylines / اختر الخطوط المغلقة: ")
      (if (setq ss (ssget '((0 . "LWPOLYLINE") (-4 . "&=") (70 . 1))))
        (progn
          (repeat (setq i (sslength ss))
            (setq ent (ssname ss (setq i (1- i))))
            (setq obj (vlax-ename->vla-object ent))
            (setq oldArea (vla-get-area obj))

            ;; الخطوة 1: عمل أوفست مبدئي
            (setq param (vl-catch-all-apply 'vla-offset (list obj distVal)))

            (if (not (vl-catch-all-error-p param))
              (progn
                (setq newObjList (vlax-variant-value param))
                (setq newObj (vlax-safearray-get-element newObjList 0))
                (setq newArea (vla-get-area newObj))

                ;;; الخطوة 2: التحقق من الاتجاه وتصحيحه
                ;;; إذا كان المطلوب "للداخل" والمساحة زادت -> نحذف ونعكس
                ;;; إذا كان المطلوب "للخارج" والمساحة نقصت -> نحذف ونعكس
                
                (cond
                  ;; حالة المطلوب "داخل" لكن النتيجة "خارج"
                  ((and (= dirOpt "Inside") (> newArea oldArea))
                     (vla-delete newObj)
                     (setq param (vl-catch-all-apply 'vla-offset (list obj (- distVal))))
                     (if (not (vl-catch-all-error-p param))
                        (setq newObj (vlax-safearray-get-element (vlax-variant-value param) 0))
                     )
                  )
                  ;; حالة المطلوب "خارج" لكن النتيجة "داخل"
                  ((and (= dirOpt "Outside") (< newArea oldArea))
                     (vla-delete newObj)
                     (setq param (vl-catch-all-apply 'vla-offset (list obj (- distVal))))
                     (if (not (vl-catch-all-error-p param))
                        (setq newObj (vlax-safearray-get-element (vlax-variant-value param) 0))
                     )
                  )
                )

                ;;; الخطوة 3: تطبيق الخصائص (الطبقة واللون)
                (if (and newObj (not (vlax-erased-p newObj)))
                  (progn
                    ;; تغيير الطبقة
                    (cond
                      ((= layerOpt "Current") (vla-put-layer newObj (getvar "CLAYER")))
                      ((= layerOpt "Name") (vla-put-layer newObj inputLayerName))
                    )
                    ;; تغيير اللون
                    (vla-put-color newObj finalColor)
                  )
                )
              )
            )
          )
          (princ "\nSuccessfully Completed | Al3mer.")
        )
        (princ "\nNo valid closed polylines selected.")
      )
    )
    (princ "\nCancelled.")
  )
  (*error* nil)
  (princ)
)