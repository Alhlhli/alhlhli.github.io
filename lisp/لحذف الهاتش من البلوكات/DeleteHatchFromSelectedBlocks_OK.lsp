;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: DHB
;;; الملف الأصلي: DeleteHatchFromSelectedBlocks_OK.lsp
;;; DeleteHatchFromSelectedBlocks_FIXED.lsp
;;; Command: DHBLK
;;; Deletes direct HATCH objects from definitions of selected block references.
;;; The same block definition is processed once only.

(vl-load-com)

(defun HB:EraseHatches (blk / obj eraseList deleted)
  (setq eraseList '()
        deleted   0)

  ;; First collect the hatch objects, then delete them.
  ;; This prevents modifying a collection while it is being enumerated.
  (vlax-for obj blk
    (if (= (vla-get-ObjectName obj) "AcDbHatch")
      (setq eraseList (cons obj eraseList))
    )
  )

  (foreach obj eraseList
    (if
      (not
        (vl-catch-all-error-p
          (vl-catch-all-apply 'vla-Delete (list obj))
        )
      )
      (setq deleted (1+ deleted))
    )
  )
  deleted
)

(defun c:DHBLK (/ *error* doc ss i ref bname blk done total skipped)
  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))

  (defun *error* (msg)
    (if doc (vla-EndUndoMark doc))
    (if (and msg (not (wcmatch (strcase msg) "*CANCEL*,*EXIT*,*BREAK*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  ;; A prompt cannot be passed to SSGET as its first argument.
  ;; It must be written separately; the filter is then passed to SSGET.
  (prompt "\nSelect block references: ")
  (if (setq ss (ssget '((0 . "INSERT"))))
    (progn
      (vla-StartUndoMark doc)
      (setq i       0
            done    '()
            total   0
            skipped 0)

      (repeat (sslength ss)
        (setq ref   (vlax-ename->vla-object (ssname ss i))
              bname (vla-get-Name ref))

        ;; Do not process a repeated reference to the same block definition.
        (if (not (member (strcase bname) done))
          (progn
            (setq done (cons (strcase bname) done)
                  blk  (vla-Item (vla-get-Blocks doc) bname))

            ;; Do not attempt to modify external-reference definitions.
            (if (and (vlax-property-available-p blk 'IsXRef)
                     (= :vlax-true (vla-get-IsXRef blk)))
              (setq skipped (1+ skipped))
              (setq total (+ total (HB:EraseHatches blk)))
            )
          )
        )
        (setq i (1+ i))
      )

      (vla-EndUndoMark doc)
      (princ
        (strcat
          "\nDone. Deleted " (itoa total) " hatch object(s) from "
          (itoa (- (length done) skipped)) " block definition(s)."
          (if (> skipped 0)
            (strcat " Skipped " (itoa skipped) " external reference(s).")
            ""
          )
        )
      )
    )
    (princ "\nNo block references selected.")
  )
  (princ)
)

(princ "\nDHBLK loaded. Type DHBLK to delete hatches from selected blocks.")
(princ)

;;; اختصار من ثلاثة أحرف.
(defun c:DHB () (c:DHBLK))
