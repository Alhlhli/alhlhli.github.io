;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: AT0
;;; الملف الأصلي: AT0.LSP
;;; AT0 — set block attribute rotations ~180° to 0°
;;; يقوم بتحويل دوران النصوص من 180 الى 0  
;;; يمكن زيادة قيمة  السماحية 2 درجات كافتراضي  
;;; AL3MER 07-10-2025  


(vl-load-com)

(defun rad->deg (r) (* 180.0 (/ r pi)))
(defun deg->rad (d) (* pi (/ d 180.0)))
(defun normdeg (d) ; normalize to [0,360)
  (setq d (rem d 360.0))
  (if (< d 0.0) (setq d (+ d 360.0)))
  d)

(defun fix-att-rot-to-0 (att tolDeg / rot deg)
  (setq rot (vla-get-Rotation att))
  (setq deg (normdeg (rad->deg rot)))
  (if (<= (abs (- deg 180.0)) tolDeg) ; within ±tolDeg of 180
    (progn
      (vla-put-Rotation att 0.0)
      (vla-Update att)
      T)
    nil))

(defun c:AT0  (/ ss i en obj atts att changed tolDeg any)
  (princ "\nTolerance around 180 in degrees <2>: ")
  (setq tolDeg (getreal ""))
  (if (null tolDeg) (setq tolDeg 2.0)) ; default ±2°

  (princ (strcat "\nUsing tolerance ±" (rtos tolDeg 2 2) "°."))

  (if (setq ss (ssget "_:L" '((0 . "INSERT"))))
    (progn
      (repeat (setq i (sslength ss))
        (setq en  (ssname ss (setq i (1- i)))
              obj (vlax-ename->vla-object en))
        (if (= (vla-get-HasAttributes obj) :vlax-true)
          (progn
            (setq atts (vlax-safearray->list (variant-value (vla-GetAttributes obj)))
                  any  nil)
            (foreach att atts
              (if (fix-att-rot-to-0 att tolDeg) (setq any T)))
            (if any
              (progn (vla-Update obj) (setq changed (1+ (if changed changed 0)))))
          )
        )
      )
      (command "._REGEN")
      (princ (strcat "\nFinished. Blocks updated: " (itoa (fixnum (or changed 0))) "."))
    )
    (princ "\nNo blocks selected.")
  )
  (princ)
)
