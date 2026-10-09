;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: SMM
;;; الملف الأصلي: SMM.lsp
;; SMM.lsp — Sum Texts or Dimensions separately and place total
;; Prompts in English; Arabic-Indic digits supported in texts
;; Command: SMM
;; SMM.lsp — جمع أرقام النصوص المحددة وكتابة الإجمالي بارتفاع النص
;; يعمل مع TEXT و MTEXT، ويدعم الأرقام العربية-الهندية والفواصل العشرية
;; الأمر: SMM
;; AL3MER العامر بمساعدة شات جي بي تي 
;; DATE 26-8-2025 

(defun _arabic2latin (s /)
  (if (and s (= (type s) 'STR))
    (vl-string-translate
      "٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹,"  ; Arabic-Indic / Eastern Arabic-Indic + comma
      "01234567890123456789."  ; Latin digits + dot
      s)
    ""))

(defun _parse-number (s / n)
  (setq n (distof (_arabic2latin s) 2)) ; 2 = Decimal units
  n)

(defun _get-text-and-height (ename / ed typ vla str h)
  (setq ed (entget ename)
        typ (cdr (assoc 0 ed)))
  (cond
    ((= typ "TEXT")
     (list (cdr (assoc 1 ed)) (cdr (assoc 40 ed))))
    ((= typ "MTEXT")
     (setq vla (vlax-ename->vla-object ename))
     (list (vlax-get vla 'TextString) (vlax-get vla 'Height)))
  ))

(defun C:SMM ( / mode ss i cnt item ed typ txth txt h href total pt prec sty lay validCount vla meas msg)
  (vl-load-com)

  ;; Ask in English which type to sum
  (initget "Texts Dimensions")
  (setq mode (getkword "\nSum which type? [Texts/Dimensions] <Texts>: "))
  (if (null mode) (setq mode "Texts"))

  ;; Build selection filter per mode
  (setq ss
    (cond
      ((= mode "Dimensions") (ssget "_:L" '((0 . "DIMENSION"))))
      (T                    (ssget "_:L" '((0 . "TEXT,MTEXT"))))
    )
  )

  (if (not ss)
    (progn (princ "\nNothing selected.") (princ))
    (progn
      (setq total 0.0
            href  nil
            cnt   (sslength ss)
            i     0
            validCount 0)

      (if (= mode "Dimensions")
        ;; --- DIMENSIONS MODE ---
        (while (< i cnt)
          (setq item (ssname ss i)
                i    (1+ i)
                vla  (vlax-ename->vla-object item)
                meas (vlax-get vla 'Measurement))
          (if (numberp meas)
            (progn
              (setq total (+ total meas))
              (setq validCount (1+ validCount)))))
        ;; --- TEXTS MODE ---
        (while (< i cnt)
          (setq item (ssname ss i)
                i    (1+ i)
                txth (_get-text-and-height item))
          (if txth
            (progn
              (setq txt (car txth)  h (cadr txth))
              (if (and (null href) (numberp h) (> h 0.0)) (setq href h))
              (setq n (_parse-number txt))
              (if (numberp n)
                (progn
                  (setq total (+ total n))
                  (setq validCount (1+ validCount))))))))
      
      ;; Determine height
      (if (= mode "Dimensions")
        (setq href (getvar "TEXTSIZE"))
        (if (or (null href) (<= href 0.0))
          (setq href (getvar "TEXTSIZE"))))

      (if (= validCount 0)
        (princ (if (= mode "Dimensions")
                 "\nNo valid dimensions found."
                 "\nNo valid numbers found in selected texts."))
        (progn
          (setq pt (getpoint "\nSpecify insertion point for total: "))
          (if pt
            (progn
              (setq prec (getvar "LUPREC")
                    sty  (getvar "TEXTSTYLE")
                    lay  (getvar "CLAYER"))
              (entmake
                (list
                  (cons 0 "TEXT")
                  (cons 8 lay)
                  (cons 7 sty)
                  (cons 10 pt)
                  (cons 40 href)
                  (cons 1 (rtos total 2 prec))
                  (cons 50 0.0)))
              (setq msg
                (if (= mode "Dimensions")
                  (strcat "\nTotal = " (rtos total 2 prec)
                          "  (SMMed " (itoa validCount) " dimensions)")
                  (strcat "\nTotal = " (rtos total 2 prec)
                          "  (SMMed " (itoa validCount) " numbers)")))
              (princ msg))
            (princ "\nCanceled before specifying insertion point.")
          )
        )
      )
    )
  )
  (princ)
)
