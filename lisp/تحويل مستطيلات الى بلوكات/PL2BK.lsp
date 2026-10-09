;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: PBK
;;; الملف الأصلي: PL2BK.lsp
(defun c:PL2BK (/ ss blkName i ent obj minpt maxpt cenpt ss-list)
  (vl-load-com)
  
  (prompt "\nاختر العناصر المراد تحويلها (سيتم وضع البلوك في نفس مكانها الحالي):")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  
  (if ss
    (progn
      (setq blkName (getstring t "\nأدخل اسم البلوك الجديد: "))
      
      (if (and blkName (/= blkName ""))
        (progn
          ;; تحويل السليكشن ليدخل في قائمة للمعالجة
          (setq i 0)
          (repeat (sslength ss)
            (setq ent (ssname ss i))
            (setq obj (vlax-ename->vla-object ent))
            
            ;; حساب المركز الهندسي الدقيق
            (vla-getboundingbox obj 'minpt 'maxpt)
            (setq minpt (vlax-safearray->list minpt)
                  maxpt (vlax-safearray->list maxpt))
            (setq cenpt (list (/ (+ (car minpt) (car maxpt)) 2.0)
                             (/ (+ (cadr minpt) (cadr maxpt)) 2.0)
                             0.0))
            
            (if (= i 0)
              ;; إنشاء تعريف البلوك من أول عنصر
              (progn
                (command "-block" blkName cenpt ent "")
                ;; إعادة إدراج النسخة الأولى في مكانها الأصلي
                (command "-insert" blkName cenpt "1" "1" "0")
              )
              ;; بقية العناصر: حذف العنصر القديم وإدراج البلوك مكانه
              (progn
                (entdel ent)
                (command "-insert" blkName cenpt "1" "1" "0")
              )
            )
            (setq i (1+ i))
          )
          (princ (strcat "\nتم استبدال " (itoa i) " عناصر بنجاح في مواقعها الأصلية."))
        )
        (princ "\nإلغاء: لم يتم تسمية البلوك.")
      )
    )
    (princ "\nلم يتم اختيار أي عناصر.")
  )
  (princ)
)
;;; اختصار من ثلاثة أحرف.
(defun c:PBK () (c:PL2BK))
