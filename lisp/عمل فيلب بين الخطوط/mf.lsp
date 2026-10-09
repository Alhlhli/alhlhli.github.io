;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: MFL
;;; الملف الأصلي: mf.lsp
;; Multi Fillet V2 - Fixed for All AutoCAD Versions
;; برنامج الفيليت المتعدد الإصدار الثاني - مُحسن لجميع إصدارات الأوتوكاد
;; يدعم الخطوط العادية والبولي لاين مع حلول بديلة للأوامر

;; دالة للتحقق من وجود أمر معين
(defun command-exists-p (cmd-name)
  (not (vl-catch-all-error-p 
    (vl-catch-all-apply 'command (list cmd-name))))
)

;; دالة لإيجاد أمر الفيليت المتاح
(defun find-fillet-command ()
  (cond
    ;; محاولة الأوامر المختلفة بالترتيب
    ((command-exists-p "._FILLET") "._FILLET")
    ((command-exists-p ".FILLET") ".FILLET")
    ((command-exists-p "FILLET") "FILLET")
    ((command-exists-p "_FILLET") "_FILLET")
    ((command-exists-p "F") "F")
    ;; في حالة عدم وجود أي أمر فيليت
    (t nil)
  )
)

;; دالة مساعدة للتحقق من نوع الكائن
(defun get-entity-type (ename)
  (cdr (assoc 0 (entget ename)))
)

;; دالة مساعدة لعرض معلومات الكائن
(defun display-entity-info (ename index)
  (setq etype (get-entity-type ename))
  (princ (strcat "\n  [" (itoa (+ index 1)) "] Type: " etype 
                 " / النوع: " 
                 (cond 
                   ((= etype "LINE") "خط عادي")
                   ((= etype "LWPOLYLINE") "بولي لاين خفيف")
                   ((= etype "POLYLINE") "بولي لاين تقليدي")
                   (t "غير معروف")
                 )))
)

;; دالة تنفيذ الفيليت الآمن
(defun safe-fillet (fillet-cmd radius line1 line2)
  (setq old-cmdecho (getvar "CMDECHO"))
  (setq old-cmderr (getvar "CMDERR"))
  (setvar "CMDECHO" 0)
  (setvar "CMDERR" 0)
  
  (setq result 
    (not (vl-catch-all-error-p 
      (vl-catch-all-apply 'command 
        (list fillet-cmd "_R" radius line1 line2)))))
  
  (setvar "CMDECHO" old-cmdecho)
  (setvar "CMDERR" old-cmderr)
  result
)

;; الأمر الرئيسي للفيليت المتعدد الإصدار الثاني المُصحح
(defun c:MF2 (/ fillet-cmd radius lines1 lines2 count i line1 line2 etype1 etype2 preview)
  
  (princ "\n=== Multi Fillet V2 - Fixed === فيليت متعدد الإصدار الثاني - مُصحح ===")
  
  ;; البحث عن أمر الفيليت المتاح
  (setq fillet-cmd (find-fillet-command))
  
  (if (null fillet-cmd)
    (progn
      (princ "\n*** ERROR: FILLET command not found! ***")
      (princ "\n*** خطأ: لم يتم العثور على أمر الفيليت! ***")
      (princ "\nPlease check your AutoCAD installation.")
      (princ "\nيرجى التحقق من تثبيت الأوتوكاد.")
      (exit)
    )
    (princ (strcat "\nUsing fillet command: " fillet-cmd " / استخدام أمر الفيليت: " fillet-cmd))
  )
  
  ;; خيار المعاينة
  (initget "Yes No")
  (setq preview (getkword "\nEnable preview mode? [Yes/No] / تفعيل وضع المعاينة؟ <No>: "))
  (if (null preview) (setq preview "No"))
  
  ;; طلب نصف قطر الفيليت مع قيم اقتراحية
  (princ "\nSuggested radii: 0.25, 0.5, 1, 2.5, 5, 10 / أنصاف أقطار مقترحة")
  (setq radius (getreal "\nEnter fillet radius / ادخل نصف قطر الفيليت: "))
  
  ;; التحقق من صحة القيمة المدخلة
  (cond
    ((null radius) 
     (princ "\nNo radius entered! Using default 1.0 / لم يتم إدخال نصف قطر! استخدام القيمة الافتراضية 1.0")
     (setq radius 1.0))
    ((<= radius 0)
     (princ "\nRadius must be positive! Using 1.0 / نصف القطر يجب أن يكون موجب! استخدام 1.0")
     (setq radius 1.0))
    ((> radius 1000)
     (princ "\nRadius too large! Using 10.0 / نصف القطر كبير جداً! استخدام 10.0")
     (setq radius 10.0))
  )
  
  ;; تحديد المجموعة الأولى من الخطوط والبولي لاين
  (princ "\n--- Step 1: First Selection --- الخطوة 1: التحديد الأول ---")
  (princ "\nSelect first set of lines/polylines / حدد المجموعة الأولى من الخطوط/البولي لاين:")
  (setq lines1 (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  
  ;; التحقق من التحديد الأول
  (if (null lines1)
    (progn
      (princ "\nNo entities selected! / لم يتم تحديد كائنات!")
      (exit)
    )
  )
  
  ;; عرض معلومات التحديد الأول
  (setq count (sslength lines1))
  (princ (strcat "\nFirst set: " (itoa count) " entities selected / المجموعة الأولى: " 
                 (itoa count) " كائن محدد"))
  
  ;; تحديد المجموعة الثانية من الخطوط والبولي لاين
  (princ "\n--- Step 2: Second Selection --- الخطوة 2: التحديد الثاني ---")
  (princ "\nSelect second set of lines/polylines / حدد المجموعة الثانية من الخطوط/البولي لاين:")
  (setq lines2 (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  
  ;; التحقق من التحديد الثاني
  (if (null lines2)
    (progn
      (princ "\nNo entities selected! / لم يتم تحديد كائنات!")
      (exit)
    )
  )
  
  ;; عرض معلومات التحديد الثاني
  (setq count2 (sslength lines2))
  (princ (strcat "\nSecond set: " (itoa count2) " entities selected / المجموعة الثانية: " 
                 (itoa count2) " كائن محدد"))
  
  ;; التحقق من تطابق عدد الكائنات
  (if (/= count count2)
    (progn
      (princ (strcat "\nMismatch! First set: " (itoa count) 
                     " | Second set: " (itoa count2)))
      (princ (strcat "\nعدم تطابق! المجموعة الأولى: " (itoa count) 
                     " | المجموعة الثانية: " (itoa count2)))
      (exit)
    )
  )
  
  ;; تأكيد المتابعة
  (princ "\n--- Step 3: Confirmation --- الخطوة 3: التأكيد ---")
  (initget "Yes No")
  (setq continue (getkword (strcat "\nProceed with " (itoa count) 
                                   " fillets at radius " (rtos radius) 
                                   "? [Yes/No] / المتابعة مع " (itoa count) 
                                   " فيليت بنصف قطر " (rtos radius) " <Yes>: ")))
  (if (null continue) (setq continue "Yes"))
  
  (if (= continue "No")
    (progn
      (princ "\nOperation cancelled / تم إلغاء العملية")
      (exit)
    )
  )
  
  ;; تنفيذ الفيليت مع عداد التقدم
  (princ "\n--- Step 4: Processing --- الخطوة 4: التنفيذ ---")
  (princ (strcat "\nUsing command: " fillet-cmd " with radius: " (rtos radius)))
  
  (setq i 0)
  (setq success-count 0)
  (setq error-count 0)
  
  (while (< i count)
    (setq line1 (ssname lines1 i))
    (setq line2 (ssname lines2 i))
    
    ;; عرض التقدم
    (princ (strcat "\nProcessing pair " (itoa (+ i 1)) "/" (itoa count) 
                   " | معالجة الزوج " (itoa (+ i 1)) "/" (itoa count)))
    
    ;; معاينة إذا كان مطلوباً
    (if (= preview "Yes")
      (progn
        (command "._ZOOM" "_E" line1 line2 "")
        (command "._REDRAW")
      )
    )
    
    ;; تنفيذ الفيليت الآمن
    (if (safe-fillet fillet-cmd radius line1 line2)
      (progn
        (princ "  [SUCCESS] / [نجح]")
        (setq success-count (+ success-count 1))
      )
      (progn
        (princ "  [ERROR] / [خطأ]")
        (setq error-count (+ error-count 1))
      )
    )
    
    (setq i (+ i 1))
  )
  
  ;; عرض النتائج النهائية
  (princ "\n=== Results Summary === ملخص النتائج ===")
  (princ (strcat "\nFillet command used: " fillet-cmd " / الأمر المستخدم: " fillet-cmd))
  (princ (strcat "\nTotal pairs processed: " (itoa count) 
                 " / إجمالي الأزواج المعالجة: " (itoa count)))
  (princ (strcat "\nSuccessful fillets: " (itoa success-count) 
                 " / الفيليت الناجح: " (itoa success-count)))
  (princ (strcat "\nFailed fillets: " (itoa error-count) 
                 " / الفيليت الفاشل: " (itoa error-count)))
  (princ (strcat "\nFillet radius used: " (rtos radius) 
                 " / نصف قطر الفيليت المستخدم: " (rtos radius)))
  
  ;; إنهاء البرنامج
  (princ "\n=== Operation Complete === العملية مكتملة ===")
  (princ)
)

;; أمر فيليت ذكي مُحسن
(defun c:SF2 (/ fillet-cmd lines1 lines2 count radius-option radius)
  
  (princ "\n=== Smart Fillet V2 - Fixed === فيليت ذكي الإصدار الثاني - مُصحح ===")
  
  ;; البحث عن أمر الفيليت
  (setq fillet-cmd (find-fillet-command))
  
  (if (null fillet-cmd)
    (progn
      (princ "\nFILLET command not available! / أمر الفيليت غير متاح!")
      (exit)
    )
    (princ (strcat "\nUsing: " fillet-cmd " / استخدام: " fillet-cmd))
  )
  
  ;; اختيار نصف القطر من قائمة
  (initget "0.25 0.5 1 2.5 5 10 20 Custom")
  (setq radius-option (getkword "\nSelect radius [0.25/0.5/1/2.5/5/10/20/Custom] / اختر نصف القطر <1>: "))
  (if (null radius-option) (setq radius-option "1"))
  
  (cond
    ((= radius-option "0.25") (setq radius 0.25))
    ((= radius-option "0.5") (setq radius 0.5))
    ((= radius-option "1") (setq radius 1.0))
    ((= radius-option "2.5") (setq radius 2.5))
    ((= radius-option "5") (setq radius 5.0))
    ((= radius-option "10") (setq radius 10.0))
    ((= radius-option "20") (setq radius 20.0))
    ((= radius-option "Custom") 
     (setq radius (getreal "\nEnter custom radius / ادخل نصف قطر مخصص: "))
     (if (or (null radius) (<= radius 0)) (setq radius 1.0)))
  )
  
  ;; تحديد الكائنات
  (princ "\nSelect first set / حدد المجموعة الأولى:")
  (setq lines1 (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  
  (if (null lines1) (exit))
  
  (princ "\nSelect second set / حدد المجموعة الثانية:")
  (setq lines2 (ssget '((0 . "LINE,LWPOLYLINE,POLYLINE"))))
  
  (if (null lines2) (exit))
  
  (setq count (sslength lines1))
  
  (if (/= count (sslength lines2))
    (progn
      (princ "\nCount mismatch! / عدم تطابق العدد!")
      (exit)
    )
  )
  
  ;; تنفيذ سريع مع معالجة الأخطاء
  (princ (strcat "\nProcessing " (itoa count) " pairs with radius " (rtos radius) "..."))
  
  (setq old-cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  
  (setq i 0)
  (setq success 0)
  (while (< i count)
    (if (safe-fillet fillet-cmd radius (ssname lines1 i) (ssname lines2 i))
      (setq success (+ success 1))
    )
    (setq i (+ i 1))
  )
  
  (setvar "CMDECHO" old-cmdecho)
  
  (princ (strcat "\nSmart fillet completed! " (itoa success) "/" (itoa count) 
                 " successful with radius " (rtos radius)
                 "\nفيليت ذكي مكتمل! " (itoa success) "/" (itoa count) 
                 " ناجح بنصف قطر " (rtos radius)))
  (princ)
)

;; أمر فيليت بسيط للاختبار
(defun c:TF (/ fillet-cmd)
  (princ "\n=== Test Fillet === اختبار الفيليت ===")
  
  (setq fillet-cmd (find-fillet-command))
  
  (if fillet-cmd
    (princ (strcat "\nFillet command found: " fillet-cmd " / تم العثور على أمر الفيليت: " fillet-cmd))
    (princ "\nNo fillet command found! / لم يتم العثور على أمر الفيليت!")
  )
  
  ;; اختبار الأمر
  (if fillet-cmd
    (progn
      (princ "\nTesting command... / اختبار الأمر...")
      (setq old-cmdecho (getvar "CMDECHO"))
      (setvar "CMDECHO" 1)
      (command fillet-cmd)
      (setvar "CMDECHO" old-cmdecho)
    )
  )
  (princ)
)

;; رسائل المساعدة
(princ "\n")
(princ "\n╔══════════════════════════════════════╗")
(princ "\n║    Multi-Fillet V2 - FIXED          ║")
(princ "\n║    فيليت متعدد الإصدار الثاني      ║")
(princ "\n║           - مُصحح -                 ║")
(princ "\n╚══════════════════════════════════════╝")
(princ "\n")
(princ "\nCompatible with ALL AutoCAD versions!")
(princ "\nمتوافق مع جميع إصدارات الأوتوكاد!")
(princ "\n")
(princ "\nAvailable Commands / الأوامر المتاحة:")
(princ "\n  TF   - Test Fillet Command / اختبار أمر الفيليت")
(princ "\n  SF2  - Smart Fillet (Fixed) / الفيليت الذكي (مُصحح)")
(princ "\n  MF2  - Advanced Multi Fillet / الفيليت المتعدد المتقدم")
(princ "\n")
(princ "\nStart with TF to test your system!")
(princ "\nابدأ بـ TF لاختبار النظام!")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:MFL () (c:MF2))
