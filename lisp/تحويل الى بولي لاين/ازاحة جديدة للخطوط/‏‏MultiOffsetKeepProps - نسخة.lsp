;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: MOF
;;; الملف الأصلي: ‏‏MultiOffsetKeepProps - نسخة.lsp
(defun c:changespacing ()
  ;; متغيرات محلية
  (setq oldError *error*)
  (setq *error* errorHandler)
  
  ;; طلب الإزاحة الجديدة من المستخدم
  (setq newSpacing (getreal "\nادخل المسافة الجديدة بين الخطوط: "))
  
  ;; التحقق من صحة الإدخال
  (if (and newSpacing (> newSpacing 0))
    (progn
      ;; طلب اختيار الخط المرجعي الثابت
      (princ "\nاختر الخط المرجعي الثابت (الذي سيبقى في مكانه): ")
      (setq refLine (car (entsel)))
      
      (if refLine
        (progn
          ;; حذف الخطوط الموجودة (عدا المرجعي)
          (princ "\nاختر جميع الخطوط المراد حذفها وإعادة إنشائها بالمسافة الجديدة: ")
          (setq selectionSet (ssget '((0 . "LWPOLYLINE,LINE"))))
          
          (if selectionSet
            (progn
              ;; حذف الخطوط المحددة (عدا المرجعي)
              (setq i 0)
              (repeat (sslength selectionSet)
                (setq currentEnt (ssname selectionSet i))
                (if (/= currentEnt refLine)
                  (entdel currentEnt)
                )
                (setq i (1+ i))
              )
              
              ;; السؤال عن عدد الخطوط المطلوب إنشاؤها
              (setq numLines (getint "\nكم عدد الخطوط المراد إنشاؤها على كل جهة؟ "))
              
              (if (and numLines (> numLines 0))
                (progn
                  ;; إنشاء خطوط جديدة باستخدام OFFSET
                  (setq currentOffset newSpacing)
                  
                  ;; إنشاء خطوط على الجهة الأولى
                  (repeat numLines
                    (command "offset" currentOffset refLine "0,1000" "")
                    (setq currentOffset (+ currentOffset newSpacing))
                  )
                  
                  ;; إنشاء خطوط على الجهة الثانية
                  (setq currentOffset newSpacing)
                  (repeat numLines
                    (command "offset" currentOffset refLine "0,-1000" "")
                    (setq currentOffset (+ currentOffset newSpacing))
                  )
                  
                  (princ (strcat "\nتم إنشاء " (itoa (* numLines 2)) " خط جديد بمسافة " (rtos newSpacing) " بنجاح!"))
                )
                (princ "\nعدد الخطوط غير صحيح.")
              )
            )
            (princ "\nلم يتم اختيار أي خطوط.")
          )
        )
        (princ "\nلم يتم اختيار خط مرجعي صحيح.")
      )
    )
    (princ "\nقيمة المسافة غير صحيحة.")
  )
  
  ;; استعادة معالج الأخطاء
  (setq *error* oldError)
  (princ)
)


;; دالة محسنة تحافظ على الخطوط الموجودة وتعيد ترتيبها
(defun c:respace ()
  (setq oldError *error*)
  (setq *error* errorHandler)
  
  ;; طلب الإزاحة الجديدة
  (setq newSpacing (getreal "\nادخل المسافة الجديدة بين الخطوط: "))
  
  (if (and newSpacing (> newSpacing 0))
    (progn
      ;; اختيار الخط المرجعي
      (princ "\nاختر الخط المرجعي الثابت: ")
      (setq refLine (car (entsel)))
      
      (if refLine
        (progn
          ;; اختيار الخطوط المراد إعادة ترتيبها
          (princ "\nاختر الخطوط المراد إعادة ترتيبها: ")
          (setq selectionSet (ssget '((0 . "LINE"))))
          
          (if selectionSet
            (progn
              ;; جمع معلومات الخطوط
              (setq linesList '())
              (setq refData (entget refLine))
              (setq refStart (cdr (assoc 10 refData)))
              (setq refEnd (cdr (assoc 11 refData)))
              
              ;; تحليل الخطوط وتصنيفها
              (setq i 0)
              (repeat (sslength selectionSet)
                (setq currentEnt (ssname selectionSet i))
                (if (/= currentEnt refLine)
                  (progn
                    (setq currentData (entget currentEnt))
                    (setq currentStart (cdr (assoc 10 currentData)))
                    (setq side (getLineSide currentStart refStart refEnd))
                    (setq linesList (cons (list currentEnt side) linesList))
                  )
                )
                (setq i (1+ i))
              )
              
              ;; فصل الخطوط حسب الجهة
              (setq upperLines '())
              (setq lowerLines '())
              
              (foreach lineInfo linesList
                (if (> (cadr lineInfo) 0)
                  (setq upperLines (cons (car lineInfo) upperLines))
                  (setq lowerLines (cons (car lineInfo) lowerLines))
                )
              )
              
              ;; حذف الخطوط القديمة
              (foreach lineInfo linesList
                (entdel (car lineInfo))
              )
              
              ;; إنشاء خطوط جديدة في الجهة العلوية
              (setq currentOffset newSpacing)
              (repeat (length upperLines)
                (command "offset" currentOffset refLine pause "")
                (setq currentOffset (+ currentOffset newSpacing))
              )
              
              ;; إنشاء خطوط جديدة في الجهة السفلية
              (setq currentOffset newSpacing)
              (repeat (length lowerLines)
                (command "offset" (- currentOffset) refLine pause "")
                (setq currentOffset (+ currentOffset newSpacing))
              )
              
              (princ (strcat "\nتم إعادة ترتيب " (itoa (length linesList)) " خط بمسافة جديدة " (rtos newSpacing)))
            )
            (princ "\nلم يتم اختيار خطوط.")
          )
        )
        (princ "\nلم يتم اختيار خط مرجعي.")
      )
    )
    (princ "\nمسافة غير صحيحة.")
  )
  
  (setq *error* oldError)
  (princ)
)


;; دالة أوتوماتيكية لإنشاء خطوط متوازية
(defun c:autooffset ()
  (setq oldError *error*)
  (setq *error* errorHandler)
  
  ;; اختيار الخط المرجعي
  (princ "\nاختر الخط المرجعي: ")
  (setq refLine (car (entsel)))
  
  (if refLine
    (progn
      ;; طلب المسافة
      (setq spacing (getreal "\nادخل المسافة بين الخطوط: "))
      
      (if (and spacing (> spacing 0))
        (progn
          ;; طلب عدد الخطوط على كل جهة
          (setq numLines (getint "\nعدد الخطوط على كل جهة: "))
          
          (if (and numLines (> numLines 0))
            (progn
              ;; إنشاء خطوط على الجهة الموجبة
              (setq currentOffset spacing)
              (repeat numLines
                (command "offset" currentOffset refLine pause "")
                (setq currentOffset (+ currentOffset spacing))
              )
              
              ;; إنشاء خطوط على الجهة السالبة
              (setq currentOffset spacing)
              (repeat numLines
                (command "offset" (- currentOffset) refLine pause "")
                (setq currentOffset (+ currentOffset spacing))
              )
              
              (princ (strcat "\nتم إنشاء " (itoa (* numLines 2)) " خط جديد"))
            )
            (princ "\nعدد غير صحيح.")
          )
        )
        (princ "\nمسافة غير صحيحة.")
      )
    )
    (princ "\nلم يتم اختيار خط.")
  )
  
  (setq *error* oldError)
  (princ)
)


;; دالة تحديد جهة النقطة بالنسبة للخط
(defun getLineSide (point lineStart lineEnd)
  (setq crossProduct (- (* (- (car lineEnd) (car lineStart)) (- (cadr point) (cadr lineStart)))
                        (* (- (cadr lineEnd) (cadr lineStart)) (- (car point) (car lineStart)))))
  (if (> crossProduct 0) 1 -1)
)


;; معالج الأخطاء
(defun errorHandler (msg)
  (if (/= msg "Function cancelled")
    (princ (strcat "\nخطأ: " msg))
  )
  (setq *error* oldError)
  (princ)
)


;; دالة مساعدة لإنشاء خطوط اختبار
(defun c:createtestlines ()
  (command "line" '(0 0) '(100 0) "")      ; الخط المرجعي
  (command "line" '(0 0.5) '(100 0.5) "")  ; خط على مسافة 0.5
  (command "line" '(0 1.0) '(100 1.0) "")  ; خط على مسافة 1.0
  (command "line" '(0 1.5) '(100 1.5) "")  ; خط على مسافة 1.5
  (command "line" '(0 2.0) '(100 2.0) "")  ; خط على مسافة 2.0
  (princ "\nتم إنشاء خطوط اختبار بمسافات 0.5 بين كل خط والآخر")
)


(princ "\nتم تحميل الأوامر:")
(princ "\nCHANGESPACING - لحذف وإعادة إنشاء خطوط بمسافة جديدة")
(princ "\nRESPACE - لإعادة ترتيب الخطوط الموجودة")
(princ "\nAUTOOFFSET - لإنشاء خطوط متوازية تلقائياً")
(princ "\nCREATETESTLINES - لإنشاء خطوط اختبار")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:MOF () (c:changespacing))
