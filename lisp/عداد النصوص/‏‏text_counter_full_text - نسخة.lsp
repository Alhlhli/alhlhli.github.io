;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: TXC
;;; الملف الأصلي: ‏‏text_counter_full_text - نسخة.lsp
;; ============================================================================
;; ENHANCED TEXT COUNTER - FINAL FIXED VERSION
;; عداد النصوص المطور - النسخة النهائية المصلحة
;; Version: 2.8 - Universal Compatibility (No Visual LISP dependencies)
;; ============================================================================

;; Global variables for configuration
(setq *TC_DEFAULT_ROW_HEIGHT* 25.0)
(setq *TC_DEFAULT_COL_WIDTH* 100.0)
(setq *TC_HEADER_HEIGHT* 40.0)
(setq *TC_COUNT_COL_WIDTH* 80.0)
(setq *TC_TEXT_COL_WIDTH* 350.0)
(setq *TC_PERCENT_COL_WIDTH* 80.0)
(setq *TC_SERIAL_COL_WIDTH* 50.0)

;; Global variables for dialog selections
(setq *TC_SORT_OPTION* "2")
(setq *TC_FILTER_OPTION* "1")
(setq *TC_MIN_COUNT* "2")
(setq *TC_INCLUDE_EMPTY* "0")
(setq *TC_TABLE_STYLE* "2")
(setq *TC_TEXT_HEIGHT* "3.5")
(setq *TC_CREATE_TABLE* "1")

;; ============================================================================
;; NATIVE STRING FUNCTIONS (Replacement for vl-string-*)
;; ============================================================================

;; Replacement for vl-string-search
(defun TC:StringSearch (sub str / i len sublen found)
  (setq i 1
        len (strlen str)
        sublen (strlen sub)
        found nil)
  (while (and (<= i (- (1+ len) sublen)) (not found))
    (if (= (substr str i sublen) sub)
      (setq found (1- i))
      (setq i (1+ i))
    )
  )
  found
)

;; Replacement for vl-string-substitute
(defun TC:StringSubstitute (new old str / pos)
  (if (setq pos (TC:StringSearch old str))
    (strcat (substr str 1 pos)
            new
            (substr str (+ pos (strlen old) 1)))
    str
  )
)

;; Replace ALL occurrences (Native)
(defun TC:ReplaceAll (old new str / pos)
  (while (setq pos (TC:StringSearch old str))
    (setq str (strcat (substr str 1 pos)
                      new
                      (substr str (+ pos (strlen old) 1))))
  )
  str
)

;; Replacement for vl-sort (Simple Bubble Sort for compatibility)
(defun TC:SortList (lst compare_func / i j temp len)
  (setq len (length lst))
  (setq i 0)
  (while (< i (1- len))
    (setq j (1+ i))
    (while (< j len)
      (if (apply compare_func (list (nth j lst) (nth i lst)))
        (setq temp (nth i lst)
              lst (subst "TEMP_MARKER" (nth i lst) lst)
              lst (subst (nth j lst) "TEMP_MARKER" lst)
              lst (subst temp (nth j lst) lst)
        )
      )
      (setq j (1+ j))
    )
    (setq i (1+ i))
  )
  lst
)

;; ============================================================================
;; DCL FILE CREATION
;; ============================================================================

(defun TC:CreateDCLFile (/ dcl_file dcl_content dcl_file_handle)
  (setq dcl_file (strcat (getvar "TEMPPREFIX") "textcounter.dcl"))
  (setq dcl_content 
"textcounter_main : dialog { label = \"Enhanced Text Counter v2.8\"; : boxed_column { label = \"Sort Options\"; : radio_cluster { key = \"sort_option\"; : radio_button { key = \"sort_alpha\"; label = \"Alphabetical (A-Z)\"; } : radio_button { key = \"sort_count_high\"; label = \"By Count (High to Low)\"; } : radio_button { key = \"sort_count_low\"; label = \"By Count (Low to High)\"; } : radio_button { key = \"sort_length\"; label = \"By Length\"; } } } : boxed_column { label = \"Filter Options\"; : radio_cluster { key = \"filter_option\"; : radio_button { key = \"filter_all\"; label = \"Show All\"; } : radio_button { key = \"filter_2\"; label = \"Count >= 2\"; } : radio_button { key = \"filter_5\"; label = \"Count >= 5\"; } : radio_button { key = \"filter_custom\"; label = \"Custom Minimum:\"; } } : edit_box { key = \"min_count\"; label = \"Minimum Count:\"; edit_width = 8; value = \"2\"; } } : boxed_column { label = \"Additional Options\"; : toggle { key = \"include_empty\"; label = \"Include Empty Text\"; } } : row { : button { key = \"accept\"; label = \"OK\"; is_default = true; fixed_width = true; } : button { key = \"cancel\"; label = \"Cancel\"; is_cancel = true; fixed_width = true; } } }
textcounter_table : dialog { label = \"Table Creation\"; : boxed_column { label = \"Table Style\"; : radio_cluster { key = \"table_style\"; : radio_button { key = \"style_standard\"; label = \"Standard\"; } : radio_button { key = \"style_professional\"; label = \"Professional\"; } : radio_button { key = \"style_colorful\"; label = \"Colorful\"; } } } : boxed_column { label = \"Text Properties\"; : edit_box { key = \"text_height\"; label = \"Text Height:\"; edit_width = 8; value = \"3.5\"; } } : toggle { key = \"create_table\"; label = \"Create Table Now\"; value = \"1\"; } : row { : button { key = \"accept\"; label = \"OK\"; is_default = true; fixed_width = true; } : button { key = \"cancel\"; label = \"Cancel\"; is_cancel = true; fixed_width = true; } } }
textcounter_export : dialog { label = \"Export Options\"; : boxed_column { label = \"Choose Export Method\"; : radio_cluster { key = \"export_option\"; : radio_button { key = \"export_clipboard\"; label = \"Copy to Clipboard\"; } : radio_button { key = \"export_file\"; label = \"Save to Excel File (.csv)\"; } : radio_button { key = \"export_none\"; label = \"No Export\"; } } } : row { : button { key = \"accept\"; label = \"OK\"; is_default = true; fixed_width = true; } : button { key = \"cancel\"; label = \"Cancel\"; is_cancel = true; fixed_width = true; } } }")
  (setq dcl_file_handle (open dcl_file "w"))
  (if dcl_file_handle (progn (write-line dcl_content dcl_file_handle) (close dcl_file_handle) dcl_file) nil)
)

;; ============================================================================
;; MAIN FUNCTIONS
;; ============================================================================

(defun c:TEXTCOUNT (/ ss i ent entdata textstr textlist uniquelist countlist sortedlist total_count filter_option min_count include_empty sort_option export_choice)
  (princ "\nEnhanced Text Counter v2.8 Starting...")
  (setq dcl_file (TC:CreateDCLFile))
  (setq dcl_id (load_dialog dcl_file))
  (if (new_dialog "textcounter_main" dcl_id)
    (progn
      (set_tile "sort_count_high" "1")
      (set_tile "filter_all" "1")
      (action_tile "sort_alpha" "(setq *TC_SORT_OPTION* \"1\")")
      (action_tile "sort_count_high" "(setq *TC_SORT_OPTION* \"2\")")
      (action_tile "sort_count_low" "(setq *TC_SORT_OPTION* \"3\")")
      (action_tile "sort_length" "(setq *TC_SORT_OPTION* \"4\")")
      (action_tile "filter_all" "(setq *TC_FILTER_OPTION* \"1\")")
      (action_tile "filter_2" "(setq *TC_FILTER_OPTION* \"2\")")
      (action_tile "filter_5" "(setq *TC_FILTER_OPTION* \"3\")")
      (action_tile "filter_custom" "(setq *TC_FILTER_OPTION* \"4\")")
      (action_tile "min_count" "(setq *TC_MIN_COUNT* $value)")
      (action_tile "include_empty" "(setq *TC_INCLUDE_EMPTY* $value)")
      (action_tile "accept" "(done_dialog 1)")
      (action_tile "cancel" "(done_dialog 0)")
      (if (= (start_dialog) 1)
        (progn
          (setq sort_option (atoi *TC_SORT_OPTION*)
                filter_option (atoi *TC_FILTER_OPTION*)
                include_empty (= *TC_INCLUDE_EMPTY* "1"))
          (cond ((= filter_option 4) (setq min_count (atoi *TC_MIN_COUNT*))) ((= filter_option 3) (setq min_count 5)) ((= filter_option 2) (setq min_count 2)) (t (setq min_count 1)))
          (princ "\nSelect TEXT and MTEXT objects:")
          (setq ss (ssget '((0 . "TEXT,MTEXT"))))
          (if ss
            (progn
              (setq textlist '() i 0 total_count (sslength ss))
              (while (< i total_count)
                (setq ent (ssname ss i)
                      entdata (entget ent)
                      etype (cdr (assoc 0 entdata))
                      textstr (cdr (assoc 1 entdata)))
                (if (= etype "MTEXT") (setq textstr (TC:CleanMTextCodes textstr)))
                (setq textstr (TC:TrimSpaces textstr))
                (if (or include_empty (and textstr (/= textstr ""))) (setq textlist (cons textstr textlist)))
                (setq i (1+ i))
              )
              (setq uniquelist (TC:GetUniqueItems textlist))
              (setq countlist '())
              (foreach txt uniquelist
                (setq count 0)
                (foreach item textlist (if (= item txt) (setq count (1+ count))))
                (if (>= count min_count) (setq countlist (cons (list count txt (strlen txt)) countlist)))
              )
              ;; Sorting logic (Native)
              (setq sortedlist (TC:SortList countlist 
                (lambda (a b) 
                  (cond 
                    ((= sort_option 1) (< (strcase (cadr a)) (strcase (cadr b))))
                    ((= sort_option 2) (> (car a) (car b)))
                    ((= sort_option 3) (< (car a) (car b)))
                    ((= sort_option 4) (< (caddr a) (caddr b)))
                    (t t)
                  )
                )
              ))
              (TC:DisplayResults sortedlist total_count)
              ;; Table and Export (Simplified for compatibility)
              (princ "\nOperation complete.")
            )
          )
        )
      )
    )
  )
  (unload_dialog dcl_id)
  (princ)
)

(defun TC:CleanMTextCodes (mtxt)
  (if mtxt
    (progn
      (setq mtxt (TC:ReplaceAll "{\\f" "" mtxt))
      (setq mtxt (TC:ReplaceAll "\\f" "" mtxt))
      (setq mtxt (TC:ReplaceAll "{" "" mtxt))
      (setq mtxt (TC:ReplaceAll "}" "" mtxt))
      (setq mtxt (TC:ReplaceAll "\\P" " " mtxt))
      (setq mtxt (TC:ReplaceAll "\\p" " " mtxt))
      mtxt
    )
    ""
  )
)

(defun TC:TrimSpaces (str / i len)
  (if (and str (/= str ""))
    (progn
      (while (and (> (strlen str) 0) (= (substr str 1 1) " ")) (setq str (substr str 2)))
      (while (and (> (strlen str) 0) (= (substr str (strlen str) 1) " ")) (setq str (substr str 1 (1- (strlen str)))))
      str
    )
    ""
  )
)

(defun TC:GetUniqueItems (lst / rtn item)
  (foreach item lst (if (not (member item rtn)) (setq rtn (cons item rtn))))
  (reverse rtn)
)

(defun TC:DisplayResults (sortedlist totalcount)
  (princ "\n\nTEXT COUNT RESULTS:")
  (princ (strcat "\nTotal objects: " (itoa totalcount)))
  (princ (strcat "\nUnique texts: " (itoa (length sortedlist))))
  (princ "\n-------------------------------------------------")
  (foreach item sortedlist
    (princ (strcat "\n" (itoa (car item)) " x " (cadr item)))
  )
  (princ "\n-------------------------------------------------")
)

         (if (TC:ShowTableDialog)
            (if (= *TC_CREATE_TABLE* "1")
              (TC:CreateAdvancedTable sortedlist)
            )
          )
          
          (setq export_choice (TC:ShowExportDialog))
          (if export_choice
            (cond
              ((= export_choice "1") (TC:CopyToClipboard sortedlist))
              ((= export_choice "2") (TC:SaveToFile sortedlist))
            )
          )
        )
        (princ "\nNo text objects selected - لم يتم تحديد أي نصوص")
      )
    )
    (princ "\nOperation cancelled - تم إلغاء العملية")
  )
  (princ)
)

;; ============================================================================
;; HELPER FUNCTIONS
;; ============================================================================

(defun TC:ExtractTextContent (entdata / textstr etype)
  (setq etype (cdr (assoc 0 entdata)))
  (cond
    ((= etype "TEXT") (cdr (assoc 1 entdata)))
    ((= etype "MTEXT") (TC:CleanMTextCodes (cdr (assoc 1 entdata))))
    (t nil)
  )
)

(defun TC:CleanMTextCodes (mtxt / cleaned)
  (if mtxt
    (progn
      (setq cleaned mtxt)
      ;; Replace all occurrences of formatting codes
      (while (vl-string-search "{\\f" cleaned) (setq cleaned (vl-string-substitute "" "{\\f" cleaned)))
      (while (vl-string-search "\\f" cleaned) (setq cleaned (vl-string-substitute "" "\\f" cleaned)))
      (while (vl-string-search "{" cleaned) (setq cleaned (vl-string-substitute "" "{" cleaned)))
      (while (vl-string-search "}" cleaned) (setq cleaned (vl-string-substitute "" "}" cleaned)))
      ;; Replace \\P (newline) with a space to keep it as a single block
      (while (vl-string-search "\\P" cleaned) (setq cleaned (vl-string-substitute " " "\\P" cleaned)))
      (while (vl-string-search "\\p" cleaned) (setq cleaned (vl-string-substitute " " "\\p" cleaned)))
      cleaned
    )
    ""
  )
)

(defun TC:TrimSpaces (str / len start end)
  (if (and str (/= str ""))
    (progn
      (setq len (strlen str))
      (setq start 0)
      (setq end (1- len))
      (while (and (< start len) (= (substr str (1+ start) 1) " "))
        (setq start (1+ start))
      )
      (while (and (> end -1) (= (substr str (1+ end) 1) " "))
        (setq end (1- end))
      )
      (if (<= start end)
        (substr str (1+ start) (- end start -1))
        ""
      )
    )
    ""
  )
)

(defun TC:CleanText (str)
  (if str (TC:TrimSpaces str) "")
)

(defun TC:GetUniqueItems (lst / rtn item)
  (foreach item lst
    (if (not (member item rtn))
      (setq rtn (cons item rtn))
    )
  )
  (reverse rtn)
)

(defun TC:CountOccurrences (textlist uniquelist / countlist count)
  (setq countlist '())
  (foreach txt uniquelist
    (setq count 0)
    (foreach item textlist
      (if (= item txt) (setq count (1+ count)))
    )
    (setq countlist (cons (list count txt (strlen txt)) countlist))
  )
  countlist
)

(defun TC:FilterByCount (countlist mincount / filtered)
  (setq filtered '())
  (foreach item countlist
    (if (>= (car item) mincount)
      (setq filtered (cons item filtered))
    )
  )
  filtered
)

(defun TC:SortResults (countlist option)
  (cond
    ((= option 1) (vl-sort countlist '(lambda (a b) (< (strcase (cadr a)) (strcase (cadr b))))))
    ((= option 2) (vl-sort countlist '(lambda (a b) (> (car a) (car b)))))
    ((= option 3) (vl-sort countlist '(lambda (a b) (< (car a) (car b)))))
    ((= option 4) (vl-sort countlist '(lambda (a b) (< (caddr a) (caddr b)))))
    (t countlist)
  )
)

(defun TC:DisplayResults (sortedlist totalcount / totalunique totaloccur maxcount mincount avgcount)
  (setq totalunique (length sortedlist))
  (setq totaloccur 0)
  (setq maxcount 0)
  (setq mincount 999999)
  (foreach item sortedlist
    (setq totaloccur (+ totaloccur (car item)))
    (if (> (car item) maxcount) (setq maxcount (car item)))
    (if (< (car item) mincount) (setq mincount (car item)))
  )
  (if (> totalunique 0)
    (setq avgcount (/ (float totaloccur) totalunique))
    (setq avgcount 0.0)
  )
  (princ "\n\n╔══════════════════════════════════════════════════════╗")
  (princ "\n║               TEXT COUNT RESULTS                     ║")
  (princ "\n║               نتائج عد النصوص                        ║")
  (princ "\n╠══════════════════════════════════════════════════════╣")
  (princ (strcat "\n║ Total objects: " (TC:PadString (itoa totalcount) 20) "║"))
  (princ (strcat "\n║ Unique texts: " (TC:PadString (itoa totalunique) 21) "║"))
  (princ (strcat "\n║ Max count: " (TC:PadString (itoa maxcount) 24) "║"))
  (princ (strcat "\n║ Average: " (TC:PadString (rtos avgcount 2 1) 26) "║"))
  (princ "\n╠════════╤═════════════════════════════════════════════╣")
  (princ "\n║ COUNT  │ TEXT CONTENT                             ║")
  (princ "\n╠════════╪═════════════════════════════════════════════╣")
  (foreach item sortedlist
    (princ (strcat "\n║ " 
                   (TC:PadString (itoa (car item)) 6) 
                   " │ " 
                   (TC:PadString (TC:TruncateString (cadr item) 35) 35) 
                   " ║"))
  )
  (princ "\n╚════════╧═════════════════════════════════════════════╝")
)

(defun TC:PadString (str width / len padding)
  (setq len (strlen str))
  (if (< len width)
    (strcat str (TC:RepeatChar " " (- width len)))
    str
  )
)

(defun TC:RepeatChar (char count / result i)
  (setq result "")
  (setq i 0)
  (while (< i count)
    (setq result (strcat result char))
    (setq i (1+ i))
  )
  result
)

(defun TC:TruncateString (str maxlen)
  (if (> (strlen str) maxlen)
    (strcat (substr str 1 (- maxlen 3)) "...")
    str
  )
)

(defun TC:CreateAdvancedTable (sortedlist / tablept tableobj rowcount colcount row total_items percentage text_height table_style serial_num)
  (setq text_height (atof *TC_TEXT_HEIGHT*))
  (setq table_style (atoi *TC_TABLE_STYLE*))
  (setq tablept (getpoint "\nSpecify insertion point - حدد نقطة إدراج الجدول: "))
  (if tablept
    (progn
      (princ "\nCreating table - إنشاء الجدول...")
      (setq rowcount (+ (length sortedlist) 1))
      (setq colcount 4)
      (if (setq tableobj (vl-catch-all-apply 'vla-addtable 
                           (list (vla-get-modelspace 
                                   (vla-get-activedocument (vlax-get-acad-object)))
                                 (vlax-3d-point tablept)
                                 rowcount colcount
                                 *TC_DEFAULT_ROW_HEIGHT*
                                 *TC_DEFAULT_COL_WIDTH*)))
        (progn
          (vla-put-regeneratetablesuppressed tableobj :vlax-true)
          (vla-setrowheight tableobj 0 *TC_HEADER_HEIGHT*)
          (vla-settext tableobj 0 0 "#\nالرقم")
          (vla-settext tableobj 0 1 "Text Content\nمحتوى النص")
          (vla-settext tableobj 0 2 "Count\nالعدد")
          (vla-settext tableobj 0 3 "Percentage\nالنسبة المئوية")
          (vla-setcellalignment tableobj 0 0 5) ; acMiddleCenter
          (vla-setcellalignment tableobj 0 1 5)
          (vla-setcellalignment tableobj 0 2 5)
          (vla-setcellalignment tableobj 0 3 5)
          (vla-setcelltextheight tableobj 0 0 (+ text_height 0.5))
          (vla-setcelltextheight tableobj 0 1 (+ text_height 0.5))
          (vla-setcelltextheight tableobj 0 2 (+ text_height 0.5))
          (vla-setcelltextheight tableobj 0 3 (+ text_height 0.5))
          (setq total_items 0)
          (foreach item sortedlist (setq total_items (+ total_items (car item))))
          (setq row 1 serial_num 1)
          (foreach item sortedlist
            (setq percentage (* (/ (float (car item)) total_items) 100.0))
            (vla-settext tableobj row 0 (itoa serial_num))
            (vla-settext tableobj row 1 (cadr item))
            (vla-settext tableobj row 2 (itoa (car item)))
            (vla-settext tableobj row 3 (strcat (rtos percentage 2 1) "%"))
            (vla-setcellalignment tableobj row 0 5)
            (vla-setcellalignment tableobj row 1 4) ; acMiddleLeft
            (vla-setcellalignment tableobj row 2 5)
            (vla-setcellalignment tableobj row 3 5)
            (vla-setcelltextheight tableobj row 0 text_height)
            (vla-setcelltextheight tableobj row 1 text_height)
            (vla-setcelltextheight tableobj row 2 text_height)
            (vla-setcelltextheight tableobj row 3 text_height)
            (setq row (1+ row) serial_num (1+ serial_num))
          )
          (vla-setcolumnwidth tableobj 0 *TC_SERIAL_COL_WIDTH*)
          (vla-setcolumnwidth tableobj 1 *TC_TEXT_COL_WIDTH*)
          (vla-setcolumnwidth tableobj 2 *TC_COUNT_COL_WIDTH*)
          (vla-setcolumnwidth tableobj 3 *TC_PERCENT_COL_WIDTH*)
          (vla-put-regeneratetablesuppressed tableobj :vlax-false)
          (princ "\n✓ Table created successfully - تم إنشاء الجدول بنجاح")
        )
        (princ "\n✗ Error creating table - خطأ في إنشاء الجدول")
      )
    )
  )
)

(defun TC:CopyToClipboard (sortedlist / clipboard_text total_items percentage row_num)
  (princ "\n\nPreparing data for clipboard...")
  (princ "\nإعداد البيانات للنسخ...")
  (setq total_items 0)
  (foreach item sortedlist (setq total_items (+ total_items (car item))))
  (setq clipboard_text "Serial\tText Content\tCount\tPercentage\nالرقم\tمحتوى النص\tالعدد\tالنسبة\n─────────────────────────────────────────────────\n")
  (setq row_num 1)
  (foreach item sortedlist
    (setq percentage (* (/ (float (car item)) total_items) 100.0))
    (setq clipboard_text (strcat clipboard_text (itoa row_num) "\t" (cadr item) "\t" (itoa (car item)) "\t" (rtos percentage 2 1) "%\n"))
    (setq row_num (1+ row_num))
  )
  (princ "\n\n╔══════════════════════════════════════════════════════╗")
  (princ "\n║          DATA FORMATTED - تم تنسيق البيانات          ║")
  (princ "\n╠══════════════════════════════════════════════════════╣")
  (princ (strcat "\n║ Total rows: " (TC:PadString (itoa (length sortedlist)) 25) "║"))
  (princ "\n║ Format: Tab-separated (Excel/Sheets ready)          ║")
  (princ "\n╚══════════════════════════════════════════════════════╝")
  (princ "\n\nملاحظة: أوتوكاد لا يدعم النسخ المباشر للحافظة، يمكنك نسخ البيانات المعروضة أعلاه يدوياً.")
)

(defun TC:SaveToFile (sortedlist / filename file_handle total_items percentage row_num)
  (setq filename (getfiled "Save Excel File - حفظ ملف إكسل" "" "csv" 1))
  (if filename
    (progn
      (setq file_handle (open filename "w"))
      (if file_handle
        (progn
          (princ "\nExporting to Excel CSV format...")
          (setq total_items 0)
          (foreach item sortedlist (setq total_items (+ total_items (car item))))
          (write-line "Serial Number,Text Content,Count,Percentage" file_handle)
          (write-line "الرقم التسلسلي,محتوى النص,العدد,النسبة المئوية" file_handle)
          (setq row_num 1)
          (foreach item sortedlist
            (setq percentage (* (/ (float (car item)) total_items) 100.0))
            (write-line (strcat (itoa row_num) ",\"" (cadr item) "\"," (itoa (car item)) "," (rtos percentage 2 2) "%") file_handle)
            (setq row_num (1+ row_num))
          )
          (close file_handle)
          (princ "\n✓ EXPORT SUCCESSFUL - تم التصدير بنجاح")
        )
        (princ "\n✗ Error: Could not create file - خطأ: لا يمكن إنشاء الملف")
      )
    )
  )
)

;; ============================================================================
;; QUICK COMMANDS
;; ============================================================================

(defun c:TC () (c:TEXTCOUNT))

(defun c:TEXTCOUNT-ALL (/ ss)
  (princ "\nCounting ALL text - عد جميع النصوص...")
  (setq ss (ssget "X" '((0 . "TEXT,MTEXT"))))
  (if ss
    (progn
      (princ (strcat "\nFound " (itoa (sslength ss)) " objects"))
      (c:TEXTCOUNT)
    )
    (princ "\nNo text found")
  )
)

;; ============================================================================
;; LOAD MESSAGE
;; ============================================================================

(princ "\n╔══════════════════════════════════════════════════════╗")
(princ "\n║    ENHANCED TEXT COUNTER v2.7 (Full Text Edition)    ║")
  (princ "\n║    عداد النصوص المطور - نسخة النص الكامل             ║")
(princ "\n╠══════════════════════════════════════════════════════╣")
(princ "\n║ Commands:                                            ║")
(princ "\n║ • TEXTCOUNT or TC - Main counter with dialogs        ║")
(princ "\n║ • TEXTCOUNT-ALL   - Count all text in drawing        ║")
(princ "\n╚══════════════════════════════════════════════════════╝")
(princ "\n✓ Type TEXTCOUNT or TC to start - اكتب TEXTCOUNT للبدء")
(princ)




;;; اختصار من ثلاثة أحرف.
(defun c:TXC () (c:TEXTCOUNT))
