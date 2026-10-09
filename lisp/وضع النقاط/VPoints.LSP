;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: VPT
;;; الملف الأصلي: VPoints.LSP
(defun VPT-ReadClipboard (/ html window clipboard result)
  (setq html (vl-catch-all-apply 'vlax-create-object (list "htmlfile")))
  (if (not (vl-catch-all-error-p html))
    (progn
      (setq window (vl-catch-all-apply 'vlax-get-property (list html 'ParentWindow)))
      (if (not (vl-catch-all-error-p window))
        (progn
          (setq clipboard (vl-catch-all-apply 'vlax-get-property (list window 'ClipboardData)))
          (if (not (vl-catch-all-error-p clipboard))
            (setq result (vl-catch-all-apply 'vlax-invoke-method (list clipboard 'GetData "Text")))
        )
      )
      (if clipboard (vlax-release-object clipboard))
      (if window (vlax-release-object window))
      (vlax-release-object html)
    )
  )
  (if (vl-catch-all-error-p result) nil result)
)

(defun c:VPoints (/ clipData rows row data ptName px py pz pointCount)
  (vl-load-com)
  
  ;; وظيفة لقراءة النصوص من الحافظة (Clipboard)
  (setq clipData (vl-catch-all-apply 'VPT-ReadClipboard nil))
  
  ;; إذا فشلت الطريقة الأولى (في بعض إصدارات ويندوز)، نستخدم البديل
  (if (not clipData)
    (setq clipData (VPT-ReadClipboard))
  )

  (if (and clipData (/= clipData ""))
    (progn
      (setq rows (string-to-list (vl-string-translate "\r" "" clipData) "\n") pointCount 0) ; تقسيم النص إلى أسطر
      
      (foreach row rows
        (if (and row (/= row ""))
          (progn
            ;; تنظيف السطر وتقسيمه سواء كان الفاصل Tab أو Comma
            (setq data (split-row row))
            
            (if (>= (length data) 3)
              (progn
                (setq ptName (nth 0 data)
                      px     (atof (nth 1 data))
                      py     (atof (nth 2 data))
                      ;; التحقق من وجود Z أو افتراضها 0
                      pz     (if (nth 3 data) (atof (nth 3 data)) 0.0)
                )
                
                ;; رسم النقطة
                (if (entmake (list '(0 . "POINT") (list 10 px py pz))) (setq pointCount (1+ pointCount)))
                
                ;; كتابة النص (اسم النقطة)
                (entmake (list 
                           '(0 . "TEXT") 
                           (cons 10 (list (+ px 0.2) (+ py 0.2) pz)) 
                           (cons 40 0.2) ; ارتفاع الخط
                           (cons 1 ptName)
                         ))
              )
            )
          )
        )
      )
      (princ (strcat "\nتم رسم " (itoa pointCount) " نقطة من الحافظة."))
    )
    (princ "\nالحافظة فارغة! قم بعمل Copy للخلايا من Excel أولاً.")
  )
  (princ)
)

;; دالة لتحويل النص إلى قائمة بناءً على فاصل معين
(defun string-to-list (str delim / pos)
  (if (setq pos (vl-string-search delim str))
    (cons (substr str 1 pos)
          (string-to-list (substr str (+ pos (strlen delim))) delim))
    (list str)
  )
)

;; دالة ذكية لتقسيم السطر بناءً على Tab أو Comma
(defun split-row (str / d)
  (setq str (vl-string-translate "\t" "," str)) ; تحويل التاب إلى فاصلة
  ;; تبقى المسافات داخل أسماء النقاط كما هي
  (string-to-list str ",")
)
;;; اختصار من ثلاثة أحرف.
(defun c:VPT () (c:VPoints))
