;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: FRR
;;; الملف الأصلي: ‏‏FRR - نسخة (9).lsp
;; =========================================================================
;; Smart Find & Replace - Nested Instance Attributes & Series Engine
;; =========================================================================

(vl-load-com)

;; --- 1. دوال معالجة النصوص والسلاسل ---

(defun _strSplit (str delims / i len char cur res)
  (setq len (strlen str) cur "" i 1)
  (while (<= i len)
    (setq char (substr str i 1))
    (if (vl-string-search char delims)
      (if (/= cur "") (setq res (cons cur res) cur ""))
      (setq cur (strcat cur char))
    )
    (setq i (1+ i))
  )
  (if (/= cur "") (setq res (cons cur res)))
  (reverse res)
)

(defun _parseRules (str / clean tokens res pos f r token)
  (setq clean (vl-string-translate ",;،\t\n" "     " str))
  (setq tokens (_strSplit clean " "))
  (setq res nil)
  (foreach token tokens
    (setq token (vl-string-trim " " token))
    (if (/= token "")
      (progn
        (setq pos (vl-string-search "-" token))
        (if (null pos) (setq pos (vl-string-search "=" token)))
        (if (and pos (> pos 0))
          (progn
            (setq f (vl-string-trim " " (substr token 1 pos)))
            (setq r (vl-string-trim " " (substr token (+ pos 2))))
            (if (and (/= f "") (/= r ""))
              (setq res (cons (cons f r) res))
            )
          )
        )
      )
    )
  )
  (reverse res)
)

(defun _replaceStr (str find repl matchCase / lenF res pos pre post)
  (if (and str find (/= find "") (/= str ""))
    (progn
      (setq lenF (strlen find) res "")
      (while (setq pos (if (= matchCase 1)
                         (vl-string-search find str)
                         (vl-string-search (strcase find) (strcase str))
                       ))
        (setq pre  (substr str 1 pos))
        (setq post (substr str (+ pos lenF 1)))
        (setq res  (strcat res pre repl))
        (setq str  post)
      )
      (strcat res str)
    )
    (if str str "")
  )
)

(defun _applyRules (str ruleList matchCase / r find repl newStr oldStr totalHits)
  (setq totalHits 0 newStr (if str str ""))
  (foreach r ruleList
    (setq find (car r) repl (cdr r))
    (setq oldStr newStr)
    (setq newStr (_replaceStr newStr find repl matchCase))
    (if (/= oldStr newStr)
      (setq totalHits (1+ totalHits))
    )
  )
  (list newStr totalHits)
)

(defun _splitPrefixNum (str / i len)
  (setq len (strlen str) i len)
  (while (and (> i 0) (vl-string-search (substr str i 1) "0123456789"))
    (setq i (1- i))
  )
  (list (substr str 1 i) (if (< i len) (atoi (substr str (1+ i))) nil))
)

(defun _getEffectiveName (vIns / name)
  (if (vlax-property-available-p vIns 'EffectiveName)
    (vla-get-EffectiveName vIns)
    (vla-get-Name vIns)
  )
)

;; --- 2. معالجة الأتربيوت الفعلية (مباشرة ومتداخلة) ---

(defun _modInsertAttribs (vIns ruleList matchCase isPreview / atts att txt res cnt)
  (setq cnt 0)
  (if (and (vlax-property-available-p vIns 'HasAttributes)
           (= (vla-get-HasAttributes vIns) :vlax-true))
    (progn
      (setq atts (vlax-invoke vIns 'GetAttributes))
      (foreach att atts
        (setq txt (vla-get-TextString att))
        (setq res (_applyRules txt ruleList matchCase))
        (if (> (cadr res) 0)
          (progn
            (setq cnt (+ cnt (cadr res)))
            (if (not isPreview)
              (progn
                (vla-put-TextString att (car res))
                (vla-Update att)
              )
            )
          )
        )
      )
    )
  )
  cnt
)

;; الغوص البرمجي داخل شجرة تعريفات البلوك مع معالجة الـ ATTRIB للبلوكات المتداخلة
(defun _deepScanBlockDef (blkName ruleList matchCase isPreview / blks blkDef objName txt res cnt subName)
  (setq cnt 0)
  (if (and blkName (not (member (strcase blkName) *visitedBlocks*)))
    (progn
      (setq *visitedBlocks* (cons (strcase blkName) *visitedBlocks*))
      (setq blks (vla-get-Blocks (vla-get-ActiveDocument (vlax-get-acad-object))))
      (if (not (vl-catch-all-error-p (setq blkDef (vl-catch-all-apply 'vla-Item (list blks blkName)))))
        (if (and blkDef (= (vla-get-IsLayout blkDef) :vlax-false) (= (vla-get-IsXRef blkDef) :vlax-false))
          (vlax-for subObj blkDef
            (setq objName (vla-get-ObjectName subObj))
            (cond
              ;; 1. نصوص عادية ومتعددة داخل البلوك
              ((member objName '("AcDbText" "AcDbMText"))
               (setq txt (vla-get-TextString subObj))
               (setq res (_applyRules txt ruleList matchCase))
               (if (> (cadr res) 0)
                 (progn
                   (setq cnt (+ cnt (cadr res)))
                   (if (not isPreview) (vla-put-TextString subObj (car res)))
                 )
               )
              )
              ;; 2. قوالب الأتربيوت الافتراضية
              ((= objName "AcDbAttributeDefinition")
               (setq txt (vla-get-TextString subObj))
               (setq res (_applyRules txt ruleList matchCase))
               (if (> (cadr res) 0)
                 (progn
                   (setq cnt (+ cnt (cadr res)))
                   (if (not isPreview) (vla-put-TextString subObj (car res)))
                 )
               )
              )
              ;; 3. بلوك فرعي متداخل (قراءة وتعديل ATTRIB الخاص به + الغوص في تعريفه)
              ((= objName "AcDbBlockReference")
               ;; أ) فحص وتعديل قيم ATTRIB الحقيقية للنسخة المتداخلة
               (setq cnt (+ cnt (_modInsertAttribs subObj ruleList matchCase isPreview)))
               ;; ب) الغوص في تعريف البلوك الفرعي
               (setq subName (_getEffectiveName subObj))
               (setq cnt (+ cnt (_deepScanBlockDef subName ruleList matchCase isPreview)))
               (if (/= (vla-get-Name subObj) subName)
                 (setq cnt (+ cnt (_deepScanBlockDef (vla-get-Name subObj) ruleList matchCase isPreview)))
               )
              )
            )
          )
        )
      )
    )
  )
  cnt
)

;; --- 3. فحص العناصر المحددة ---

(defun _processEntities (ss ruleList checkNested matchCase isPreview / i e vo objName cntDirect cntNested effName rawName txt res)
  (setq cntDirect 0 cntNested 0 *visitedBlocks* nil)
  (if ss
    (repeat (setq i (sslength ss))
      (setq e (ssname ss (setq i (1- i))))
      (setq vo (vlax-ename->vla-object e))
      (setq objName (vla-get-ObjectName vo))
      (cond
        ((= objName "AcDbBlockReference")
         ;; أتربيوت المرجع الخارجي
         (setq cntDirect (+ cntDirect (_modInsertAttribs vo ruleList matchCase isPreview)))
         ;; البلوكات المتداخلة وتعريفاتها
         (if checkNested
           (progn
             (setq effName (_getEffectiveName vo))
             (setq rawName (vla-get-Name vo))
             (setq cntNested (+ cntNested (_deepScanBlockDef effName ruleList matchCase isPreview)))
             (if (/= rawName effName)
               (setq cntNested (+ cntNested (_deepScanBlockDef rawName ruleList matchCase isPreview)))
             )
           )
         )
         (if (not isPreview) (vla-Update vo))
        )
        ((= objName "AcDbAttribute")
         (setq txt (vla-get-TextString vo))
         (setq res (_applyRules txt ruleList matchCase))
         (if (> (cadr res) 0)
           (progn
             (setq cntDirect (+ cntDirect (cadr res)))
             (if (not isPreview) (progn (vla-put-TextString vo (car res)) (vla-Update vo)))
           )
         )
        )
        ((member objName '("AcDbText" "AcDbMText"))
         (setq txt (vla-get-TextString vo))
         (setq res (_applyRules txt ruleList matchCase))
         (if (> (cadr res) 0)
           (progn
             (setq cntDirect (+ cntDirect (cadr res)))
             (if (not isPreview) (progn (vla-put-TextString vo (car res)) (vla-Update vo)))
           )
         )
        )
      )
    )
  )
  (list cntDirect cntNested)
)

;; --- 4. واجهة DCL التفاعلية ---

(defun _generateDCL ( / dclFile fPath)
  (setq fPath (vl-filename-mktemp "SmartFR_Fixed.dcl"))
  (setq dclFile (open fPath "w"))
  (write-line "smart_fr_fixed : dialog {" dclFile)
  (write-line "  label = \"استبدال ذكي متقدم - معالجة ATTRIB المتداخلة\";" dclFile)
  (write-line "  : boxed_column {" dclFile)
  (write-line "    label = \"1. قائمة قواعد الاستبدال (حروف أو أرقام: C-A أو C1-A1)\";" dclFile)
  (write-line "    : edit_box { key = \"k_rules\"; width = 75; }" dclFile)
  (write-line "    : row {" dclFile)
  (write-line "      : button { key = \"btn_clear\"; label = \"مسح القائمة\"; width = 12; }" dclFile)
  (write-line "      : button { key = \"btn_auto_complete\"; label = \"إكمال ذكي تلقائي (+5)\"; }" dclFile)
  (write-line "    }" dclFile)
  (write-line "  }" dclFile)
  (write-line "  : boxed_column {" dclFile)
  (write-line "    label = \"2. مولّد المتسلسلات والحروف (Series & Letters Generator)\";" dclFile)
  (write-line "    : row {" dclFile)
  (write-line "      : edit_box { key = \"k_pfx_from\"; label = \"من (نص/بادئة):\"; width = 10; value = \"C\"; }" dclFile)
  (write-line "      : edit_box { key = \"k_pfx_to\";   label = \"إلى (نص/بديل):\"; width = 10; value = \"A\"; }" dclFile)
  (write-line "    }" dclFile)
  (write-line "    : row {" dclFile)
  (write-line "      : edit_box { key = \"k_num_start\"; label = \"من رقم (اتركه فارغاً للحروف):\"; width = 6; value = \"1\"; }" dclFile)
  (write-line "      : edit_box { key = \"k_num_end\";   label = \"إلى رقم:\"; width = 6; value = \"5\"; }" dclFile)
  (write-line "      : edit_box { key = \"k_num_to_start\"; label = \"بداية رقم البديل:\"; width = 6; value = \"1\"; }" dclFile)
  (write-line "    }" dclFile)
  (write-line "    : row {" dclFile)
  (write-line "      : toggle { key = \"k_same_num\"; label = \"تطابق الرقم (العدد يبقى نفسه)\"; value = \"1\"; }" dclFile)
  (write-line "      : button { key = \"btn_gen_series\"; label = \"توليد وإضافة للقائمة\"; }" dclFile)
  (write-line "    }" dclFile)
  (write-line "  }" dclFile)
  (write-line "  : boxed_column {" dclFile)
  (write-line "    label = \"3. خيارات المعالجة\";" dclFile)
  (write-line "    : row {" dclFile)
  (write-line "      : toggle { key = \"k_nested\"; label = \"معالجة البلوكات والسمات المتداخلة (Nested ATTRIB)\"; value = \"1\"; }" dclFile)
  (write-line "      : toggle { key = \"k_match_case\"; label = \"حساس لحالة الأحرف (Case Sensitive)\"; value = \"0\"; }" dclFile)
  (write-line "    }" dclFile)
  (write-line "  }" dclFile)
  (write-line "  : boxed_column {" dclFile)
  (write-line "    label = \"4. نتائج المعاينة والإحصاء\";" dclFile)
  (write-line "    : list_box { key = \"k_preview\"; width = 75; height = 8; }" dclFile)
  (write-line "  }" dclFile)
  (write-line "  : row {" dclFile)
  (write-line "    : button { key = \"btn_prev\"; label = \"تحديث المعاينة\"; }" dclFile)
  (write-line "    : ok_button { label = \"تنفيذ الاستبدال\"; }" dclFile)
  (write-line "    : cancel_button { label = \"إلغاء\"; }" dclFile)
  (write-line "  }" dclFile)
  (write-line "}" dclFile)
  (close dclFile)
  fPath
)

;; --- 5. أحداث الواجهة ---

(defun _doPreviewAction ( / rStr rList isNest isCase stats totalFound)
  (setq rStr (get_tile "k_rules"))
  (setq rList (_parseRules rStr))
  (setq isNest (= (get_tile "k_nested") "1"))
  (setq isCase (atoi (get_tile "k_match_case")))
  (start_list "k_preview")
  (if rList
    (progn
      (setq stats (_processEntities *ssGlobal* rList isNest isCase T))
      (setq totalFound (+ (car stats) (cadr stats)))
      (mapcar 'add_list
        (append
          (mapcar '(lambda (x) (strcat "القاعدة: [" (car x) "]  ==>  [" (cdr x) "]")) rList)
          (list "----------------------------------------------------------------------")
          (list (strcat "مطابقات السمات والنصوص الخارجية: " (itoa (car stats))))
          (list (strcat "مطابقات السمات والنصوص المتداخلة (Nested ATTRIB): " (itoa (cadr stats))))
          (list (strcat ">> إجمالي العناصر المعثور عليها للتعديل: " (itoa totalFound)))
        )
      )
    )
    (add_list "القائمة فارغة! أدخل قواعد الاستبدال أو استخدم أدوات التوليد بالأعلى.")
  )
  (end_list)
)

(defun _doGenSeriesAction ( / pFrom pTo strStart strEnd nStart nEnd nToStart sameNum newRules i curTo curStr)
  (setq pFrom    (vl-string-trim " " (get_tile "k_pfx_from")))
  (setq pTo      (vl-string-trim " " (get_tile "k_pfx_to")))
  (setq strStart (vl-string-trim " " (get_tile "k_num_start")))
  (setq strEnd   (vl-string-trim " " (get_tile "k_num_end")))
  (setq nToStart (atoi (get_tile "k_num_to_start")))
  (setq sameNum  (= (get_tile "k_same_num") "1"))

  (if (or (= strStart "") (= strEnd ""))
    (setq newRules (list (strcat pFrom "-" pTo)))
    (progn
      (setq nStart (atoi strStart) nEnd (atoi strEnd))
      (if (<= nStart nEnd)
        (progn
          (setq newRules nil i nStart)
          (while (<= i nEnd)
            (setq curTo (if sameNum i (+ nToStart (- i nStart))))
            (setq newRules (cons (strcat pFrom (itoa i) "-" pTo (itoa curTo)) newRules))
            (setq i (1+ i))
          )
          (setq newRules (reverse newRules))
        )
      )
    )
  )
  (if newRules
    (progn
      (setq curStr (vl-string-trim " ," (get_tile "k_rules")))
      (foreach r newRules
        (if (/= curStr "")
          (setq curStr (strcat curStr ", " r))
          (setq curStr r)
        )
      )
      (set_tile "k_rules" curStr)
      (_doPreviewAction)
    )
  )
)

(defun _doAutoCompleteAction ( / curStr rList lastPair sF sR pfxF numF pfxR numR step i nextRules prevPair prevF prevNumF)
  (setq curStr (get_tile "k_rules"))
  (setq rList (_parseRules curStr))
  (if rList
    (progn
      (setq lastPair (last rList))
      (setq sF (_splitPrefixNum (car lastPair)))
      (setq sR (_splitPrefixNum (cdr lastPair)))
      (setq pfxF (car sF) numF (cadr sF))
      (setq pfxR (car sR) numR (cadr sR))
      (if (and numF numR)
        (progn
          (setq step 1)
          (if (> (length rList) 1)
            (progn
              (setq prevPair (nth (- (length rList) 2) rList))
              (setq prevF (_splitPrefixNum (car prevPair)))
              (setq prevNumF (cadr prevF))
              (if (and prevNumF (> numF prevNumF))
                (setq step (- numF prevNumF))
              )
            )
          )
          (setq nextRules nil i 1)
          (repeat 5
            (setq numF (+ numF step))
            (setq numR (+ numR step))
            (setq nextRules (cons (strcat pfxF (itoa numF) "-" pfxR (itoa numR)) nextRules))
            (setq i (1+ i))
          )
          (foreach r (reverse nextRules)
            (setq curStr (strcat curStr ", " r))
          )
          (set_tile "k_rules" curStr)
          (_doPreviewAction)
        )
      )
    )
  )
)

(defun _doAcceptAction ()
  (setq *finalRulesStr* (get_tile "k_rules"))
  (setq *finalDoNested* (= (get_tile "k_nested") "1"))
  (setq *finalMatchCase* (atoi (get_tile "k_match_case")))
  (done_dialog 1)
)

;; --- 6. الأمر الرئيسي (FRR) ---

(defun c:FRR ( / *error* dclPath dclId act rulesList resStats totalDirect totalNested)
  (defun *error* (msg)
    (if (and dclId (> dclId 0)) (unload_dialog dclId))
    (if (and dclPath (findfile dclPath)) (vl-file-delete dclPath))
    (setq *ssGlobal* nil)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nخطأ: " msg))
    )
    (princ)
  )

  (princ "\n[Smart-FR] حدِّد مجموعة البلوكات أو العناصر (أو اضغط Enter لتحديد كامل الرسم)...")
  (setq *ssGlobal* (ssget '((0 . "INSERT,ATTRIB,TEXT,MTEXT"))))
  (if (null *ssGlobal*)
    (setq *ssGlobal* (ssget "_X" '((0 . "INSERT,ATTRIB,TEXT,MTEXT"))))
  )

  (if (null *ssGlobal*)
    (progn (princ "\nلم يتم العثور على أي عناصر.") (exit))
  )

  (setq dclPath (_generateDCL))
  (setq dclId (load_dialog dclPath))

  (if (not (new_dialog "smart_fr_fixed" dclId))
    (progn (princ "\nتعذر تحميل الواجهة.") (exit))
  )

  (set_tile "k_rules" "C1-A1, C2-A2, AS1-CS1, AS2-CS2")
  (_doPreviewAction)

  (action_tile "k_rules"           "(_doPreviewAction)")
  (action_tile "btn_clear"         "(set_tile \"k_rules\" \"\") (_doPreviewAction)")
  (action_tile "btn_auto_complete" "(_doAutoCompleteAction)")
  (action_tile "btn_gen_series"    "(_doGenSeriesAction)")
  (action_tile "btn_prev"          "(_doPreviewAction)")
  (action_tile "k_nested"          "(_doPreviewAction)")
  (action_tile "k_match_case"      "(_doPreviewAction)")
  (action_tile "accept"            "(_doAcceptAction)")
  (action_tile "cancel"            "(done_dialog 0)")

  (setq act (start_dialog))
  (unload_dialog dclId)
  (if (findfile dclPath) (vl-file-delete dclPath))

  ;; تطبيق الاستبدال وتحديث الرسم
  (if (= act 1)
    (progn
      (setq rulesList (_parseRules *finalRulesStr*))
      (if rulesList
        (progn
          (setq resStats (_processEntities *ssGlobal* rulesList *finalDoNested* *finalMatchCase* nil))
          (setq totalDirect (car resStats))
          (setq totalNested (cadr resStats))
          (vla-Regen (vla-get-ActiveDocument (vlax-get-acad-object)) acAllViewports)
          (princ (strcat
            "\n========================================="
            "\nتم الاستبدال بنجاح!"
            "\n- سمات ونصوص خارجية: " (itoa totalDirect)
            "\n- سمات ونصوص متداخلة (Nested ATTRIB): " (itoa totalNested)
            "\n- إجمالي التعديلات المنفذة: " (itoa (+ totalDirect totalNested)) " عنصر."
            "\n========================================="
          ))
        )
        (princ "\nلم يتم تطبيق أي تغيير (القائمة فارغة).")
      )
    )
    (princ "\nتم إلغاء العملية.")
  )

  (setq *ssGlobal* nil)
  (princ)
)