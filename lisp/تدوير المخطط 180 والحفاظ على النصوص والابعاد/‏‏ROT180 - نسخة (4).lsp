;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: ROT
;;; الملف الأصلي: ‏‏ROT180 - نسخة (4).lsp
(vl-load-com)

(defun c:FIX-MLD ( / ss i ent obj minpt maxpt p1 p2 cen pt-v pt-h old-mirrtext old-cmdecho old-osmode)
  (setq old-cmdecho  (getvar "CMDECHO")
        old-osmode   (getvar "OSMODE")
        old-mirrtext (getvar "MIRRTEXT"))

  (setvar "CMDECHO" 0)
  (setvar "OSMODE" 0)
  (setvar "MIRRTEXT" 0)

  (princ "\nSelect Multileaders to fix [Press Enter for ALL]: ")
  (setq ss (ssget '((0 . "MULTILEADER"))))
  (if (null ss)
    (setq ss (ssget "_X" (list (cons 0 "MULTILEADER") (cons 410 (getvar "CTAB")))))
  )

  (if (and ss (> (sslength ss) 0))
    (progn
      (vla-StartUndoMark (vla-get-ActiveDocument (vlax-get-acad-object)))
      (repeat (setq i (sslength ss))
        (setq ent (ssname ss (setq i (1- i))))
        (setq obj (vlax-ename->vla-object ent))
        
        ;; Get center point of the multileader
        (if (not (vl-catch-all-error-p
                   (vl-catch-all-apply 'vla-GetBoundingBox (list obj 'minpt 'maxpt))))
          (progn
            (setq p1 (vlax-safearray->list (if (= (type minpt) 'variant) (vlax-variant-value minpt) minpt))
                  p2 (vlax-safearray->list (if (= (type maxpt) 'variant) (vlax-variant-value maxpt) maxpt)))
            (setq cen (list (/ (+ (car p1) (car p2)) 2.0)
                            (/ (+ (cadr p1) (cadr p2)) 2.0)
                            0.0))
            (setq pt-v (polar cen (/ pi 2.0) 10.0)
                  pt-h (polar cen 0.0 10.0))

            ;; Double mirror flips the coordinate system and forces AutoCAD to redraw text upright
            (vl-cmdf "_.mirror" ent "" "_non" cen "_non" pt-v "_Y")
            (vl-cmdf "_.mirror" (entlast) "" "_non" cen "_non" pt-h "_Y")
          )
        )
      )
      (vla-EndUndoMark (vla-get-ActiveDocument (vlax-get-acad-object)))
      (princ (strcat "\n[FIX-MLD] Successfully normalized " (itoa (sslength ss)) " Multileaders."))
    )
    (princ "\n[FIX-MLD] No Multileaders found.")
  )

  (setvar "OSMODE" old-osmode)
  (setvar "MIRRTEXT" old-mirrtext)
  (setvar "CMDECHO" old-cmdecho)
  (princ)
)
;;; اختصار من ثلاثة أحرف.
(defun c:ROT () (c:FIX-MLD))
