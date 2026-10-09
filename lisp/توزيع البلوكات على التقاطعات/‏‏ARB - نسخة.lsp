;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: ARB
;;; الملف الأصلي: ‏‏ARB - نسخة.lsp
(defun c:ARB (/ blkSel blkEnt blkData blkObj blkName ss entList len i j ent1 ent2 rawPts k pt ptsList)
  (vl-load-com) ; تحميل مكتبات Visual LISP
  
  ; 1. تحديد البلوك بالنقر عليه
  (setq blkSel (entsel "\nحدد البلوك المراد وضعه (انقر على بلوك موجود): "))
  
  ; التحقق من أن المستخدم قام بالتحديد
  (if (not blkSel)
    (progn (princ "\nتم إلغاء الأمر.") (exit))
  )
  
  (setq blkEnt (car blkSel))
  (setq blkData (entget blkEnt))
  
  ; التحقق مما إذا كان الكائن المحدد بلوكاً (INSERT) وليس خطاً أو دائرة
  (if (/= (cdr (assoc 0 blkData)) "INSERT")
    (progn
      (princ "\nالخطأ: الكائن المحدد ليس بلوكاً. يرجى تحديد بلوك.")
      (exit)
    )
  )

  ; استخراج اسم البلوك الفعال (يدعم البلوكات الديناميكية والعادية)
  (setq blkObj (vlax-ename->vla-object blkEnt))
  (setq blkName (vla-get-EffectiveName blkObj))
  (princ (strcat "\nتم تحديد البلوك: " blkName))

  ; 2. طلب تحديد الخطوط
  (princ "\nحدد الخطوط، البولي لاين، أو الإكس لاين (Xline):")
  (setq ss (ssget '((0 . "LINE,*POLYLINE,XLINE"))))

  (if ss
    (progn
      (setq i 0)
      (setq ptsList '())
      
      ; تحويل Selection Set إلى قائمة كائنات VLA
      (setq entList (mapcar 'vlax-ename->vla-object (ss-to-list ss)))
      (setq len (length entList))
      
      (setvar "cmdecho" 0)
      
      ; 3. حلقات تكرار للبحث عن التقاطعات
      (while (< i len)
        (setq ent1 (nth i entList))
        (setq j (1+ i))
        (while (< j len)
          (setq ent2 (nth j entList))
          
          ; دالة التقاطع (IntersectWith) مع عدم تمديد الخطوط
          (setq rawPts (vlax-invoke ent1 'IntersectWith ent2 acExtendNone))
          
          ; معالجة نقاط التقاطع
          (if rawPts
            (progn
              (setq k 0)
              (while (< k (vlax-safearray-get-u-bound (vlax-variant-value rawPts) 1))
                (setq pt (vlax-safearray-get-element (vlax-variant-value rawPts) k))
                ; تقريب الإحداثيات لمنع التكرار الناتج عن أخطاء التقريب الدقيقة
                (setq pt (list (roundto (car pt) 4) (roundto (cadr pt) 4) (roundto (caddr pt) 4)))
                
                ; إضافة النقطة للقائمة إذا كانت جديدة
                (if (not (member pt ptsList))
                  (setq ptsList (cons pt ptsList))
                )
                (setq k (+ k 3))
              )
            )
          )
          (setq j (1+ j))
        )
        (setq i (1+ i))
      )

      ; 4. وضع البلوكات
      (if ptsList
        (progn
          (princ (strcat "\nتم العثور على " (itoa (length ptsList)) " نقطة تقاطع. جاري وضع البلوكات..."))
          (foreach pt ptsList
            ; استخدام الأمر insert بوضع Command Echo 0 للسرعة
            (command "._-INSERT" blkName pt "1" "1" "0")
          )
          (princ "\nتم الانتهاء.")
        )
        (princ "\nلم يتم العثور على أي تقاطعات بين الخطوط المحددة.")
      )
      
      (setvar "cmdecho" 1)
    )
    (princ "\nلم يتم تحديد أي خطوط.")
  )
  (princ)
)

; دالة مساعدة لتحويل Selection Set إلى قائمة
(defun ss-to-list (ss / i e l)
  (setq i 0)
  (repeat (sslength ss)
    (setq e (ssname ss i))
    (setq l (cons e l))
    (setq i (1+ i))
  )
  (reverse l)
)

; دالة مساعدة لتقريب الأرقام
(defun roundto (n p / m)
  (setq m (expt 10.0 p))
  (* (fix (+ (* n m) 0.5)) (/ 1.0 m))
)