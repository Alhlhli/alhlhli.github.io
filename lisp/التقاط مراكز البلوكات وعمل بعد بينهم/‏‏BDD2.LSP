;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: BDD
;;; الملف الأصلي: ‏‏BDD2.LSP
;;; =================== BDD v2 - Block Centers Dimensioning Suite ===================
;;; Features:
;;; - Auto axis selection (or force X / Y).
;;; - Dimension line locked onto a single picked coordinate.
;;; - Two modes: CONT (chained between each pair) or BASE (baseline from first center).
;;; - Outlier trimming (relative cut from both ends along the axis).
;;; - Block center: INSERT point or BoundingBox center.
;;; - Custom dimension layer + optional custom DimStyle.
;;; - Single UNDO group (ActiveX undo marks) + command-free error handler.
;;; Commands: BDD (run), BDDCFG (config), BDDHELP (quick help).

(vl-load-com)

;;; -------------------- Default configuration --------------------
(setq *bdd.cfg*
  (list
    (cons 'mode 'CONT)         ; 'CONT or 'BASE
    (cons 'axis 'AUTO)         ; 'AUTO or 'X or 'Y
    (cons 'center 'INS)        ; 'INS or 'BOX
    (cons 'cut 0.10)           ; outlier cut 0..0.45 (10% = trims 5% from each end)
    (cons 'dimlayer "DIM-BDD") ; dimension layer
    (cons 'dimstyle nil)       ; DimStyle name to use; nil = current
  )
)

(defun bdd:get (k) (cdr (assoc k *bdd.cfg*)))
(defun bdd:set (k v) (setq *bdd.cfg* (subst (cons k v) (assoc k *bdd.cfg*) *bdd.cfg*)))

;;; -------------------- Helpers --------------------
(defun bdd:doc () (vla-get-activedocument (vlax-get-acad-object)))

;; Create the layer via ActiveX (robust across CAD variants). Returns T if it exists.
(defun bdd:ensure-layer (ln)
  (if (not (tblsearch "LAYER" ln))
    (vl-catch-all-apply 'vla-add (list (vla-get-layers (bdd:doc)) ln)))
  (if (tblsearch "LAYER" ln) T)
)

;; Restore/select a named DimStyle via ActiveX (no command, safe in *error*).
(defun bdd:dimstyle-set (name / ds)
  (if (and name (/= "" name) (tblsearch "DIMSTYLE" name))
    (progn
      (setq ds (vl-catch-all-apply
                 'vla-item (list (vla-get-dimstyles (bdd:doc)) name)))
      (if (and ds (not (vl-catch-all-error-p ds)))
        (vl-catch-all-apply 'vla-put-activedimstyle (list (bdd:doc) ds)))))
  (princ)
)

(defun bdd:mid (p q) (mapcar '(lambda (x y) (/ (+ x y) 2.0)) p q))

;; coordinate along the chosen axis
(defun bdd:coord (p axis) (if (eq axis 'X) (car p) (cadr p)))

(defun bdd:box-center (en / obj mn mx)
  (setq obj (vlax-ename->vla-object en))
  (vla-getboundingbox obj 'mn 'mx)
  (setq mn (vlax-safearray->list mn)
        mx (vlax-safearray->list mx))
  (list (/ (+ (car mn) (car mx)) 2.0)
        (/ (+ (cadr mn) (cadr mx)) 2.0)
        0.0))

(defun bdd:ins-center (en) (cdr (assoc 10 (entget en))))

(defun bdd:centers (ss centerMode / i e pts)
  (setq i 0 pts '())
  (while (< i (sslength ss))
    (setq e (ssname ss i))
    (if (= (cdr (assoc 0 (entget e))) "INSERT")
      (setq pts (cons (if (eq centerMode 'BOX) (bdd:box-center e) (bdd:ins-center e)) pts)))
    (setq i (1+ i))
  )
  (reverse pts)
)

;;; Sort along the chosen axis, with a tie-break on the other axis so that
;;; vl-sort does not drop points that share the primary coordinate.
(defun bdd:sort-by (pts axis / other)
  (setq other (if (eq axis 'X) 'Y 'X))
  (vl-sort pts
    (function (lambda (a b)
      (if (equal (bdd:coord a axis) (bdd:coord b axis) 1e-9)
        (< (bdd:coord a other) (bdd:coord b other))
        (< (bdd:coord a axis)  (bdd:coord b axis))))))
)

;;; Auto axis: compare spread in X vs Y (O(n)).
(defun bdd:auto-axis (pts / xs ys)
  (setq xs (mapcar 'car pts)
        ys (mapcar 'cadr pts))
  (if (>= (- (apply 'max xs) (apply 'min xs))
          (- (apply 'max ys) (apply 'min ys)))
    'X 'Y)
)

;;; Outlier trimming along the chosen axis: drops cut/2 from each end.
(defun bdd:trim-outliers (pts axis cut / n k lo hi i sorted out)
  (setq n (length pts))
  (if (or (<= n 2) (<= cut 0.0))
    pts
    (progn
      (setq sorted (bdd:sort-by pts axis)
            k  (fix (* 0.5 cut n))
            lo k
            hi (- n k)
            i  0
            out '())
      (foreach p sorted
        (if (and (>= i lo) (< i hi)) (setq out (cons p out)))
        (setq i (1+ i)))
      (reverse out)
    )
  )
)

;;; -------------------- Main command --------------------
(defun c:BDD (/ *error* ss pts axis p1 p2 mid0 anch dpt mid rest base
                mode center cut dimlay dimsty oldlay olderr undo-open)
  (setq olderr *error*)
  (defun *error* (msg)
    (if oldlay (setvar "CLAYER" oldlay))
    (if undo-open (vl-catch-all-apply 'vla-endundomark (list (bdd:doc))))
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*QUIT*")))
      (princ (strcat "\nAborted: " msg)))
    (setq *error* olderr)
    (princ)
  )

  (prompt "\n[BDD] Select INSERTs to dimension between centers: ")
  (setq ss (ssget '((0 . "INSERT"))))
  (if (not ss)
    (prompt "\nNothing selected.")
    (progn
      (setq mode   (bdd:get 'mode)
            center (bdd:get 'center)
            cut    (bdd:get 'cut)
            dimlay (bdd:get 'dimlayer)
            dimsty (bdd:get 'dimstyle))

      ;; centers
      (setq pts (bdd:centers ss center))
      (if (< (length pts) 2)
        (prompt "\nNeed at least two points.")
        (progn
          ;; axis
          (setq axis (bdd:get 'axis))
          (if (eq axis 'AUTO) (setq axis (bdd:auto-axis pts)))
          ;; sort
          (setq pts (bdd:sort-by pts axis))
          ;; trim outliers
          (if (and cut (> cut 0.0))
            (setq pts (bdd:trim-outliers pts axis (min 0.45 (max 0.0 cut)))))

          (if (< (length pts) 2)
            (prompt "\nOnly one point left after trimming.")
            (progn
              ;; dimension line anchor
              (setq p1 (nth 0 pts) p2 (nth 1 pts) mid0 (bdd:mid p1 p2))
              (setq anch (getpoint mid0 (strcat "\nDimension line location ("
                                                (if (eq axis 'X) "horizontal: locks Y" "vertical: locks X")
                                                "): ")))
              (if (not anch)
                (prompt "\nCancelled.")
                (progn
                  ;; open undo group (ActiveX mark - safe with the error handler)
                  (vla-startundomark (bdd:doc))
                  (setq undo-open T)

                  ;; layer (only switch if it really exists) & DimStyle
                  (if (and dimlay (bdd:ensure-layer dimlay))
                    (progn (setq oldlay (getvar "CLAYER"))
                           (setvar "CLAYER" dimlay)))
                  (if dimsty (bdd:dimstyle-set dimsty))

                  ;; create dimensions
                  (cond
                    ((eq mode 'BASE)
                     ;; baseline from the first point to all others
                     (setq base (car pts) rest (cdr pts))
                     (foreach p2 rest
                       (setq mid (bdd:mid base p2)
                             dpt (if (eq axis 'X)
                                   (list (car mid) (cadr anch) 0.0)
                                   (list (car anch) (cadr mid) 0.0)))
                       (command "_.DIMLINEAR" base p2 dpt)
                     )
                    )
                    (T
                     ;; CONT chained between each adjacent pair
                     (setq rest pts)
                     (while (cdr rest)
                       (setq p1 (car rest) p2 (cadr rest) mid (bdd:mid p1 p2)
                             dpt (if (eq axis 'X)
                                   (list (car mid) (cadr anch) 0.0)
                                   (list (car anch) (cadr mid) 0.0)))
                       (command "_.DIMLINEAR" p1 p2 dpt)
                       (setq rest (cdr rest))
                     )
                    )
                  )

                  ;; restore layer & close undo group
                  (if oldlay (setvar "CLAYER" oldlay))
                  (vla-endundomark (bdd:doc))
                  (setq undo-open nil)
                  (prompt (strcat "\nDone: axis " (if (eq axis 'X) "X" "Y")
                                  ", mode " (if (eq mode 'BASE) "BASELINE" "CONTINUE")
                                  ", center " (if (eq center 'BOX) "BoundingBox" "Insertion")
                                  (if (and cut (> cut 0.0))
                                    (strcat ", cut " (rtos (* cut 100.0) 2 0) "%") "")))
                )
              )
            )
          )
        )
      )
    )
  )
  (setq *error* olderr)
  (princ)
)

;;; -------------------- Configuration --------------------
(defun c:BDDCFG (/ ans)
  (princ "\n[BDDCFG] BDD settings:")
  (initget "CONT BASE")
  (setq ans (getkword (strcat "\nMode [CONT/BASE] <" (if (eq (bdd:get 'mode) 'BASE) "BASE" "CONT") ">: ")))
  (if ans (bdd:set 'mode (read (strcase ans))))

  (initget "AUTO X Y")
  (setq ans (getkword (strcat "\nAxis [AUTO/X/Y] <" (strcase (vl-princ-to-string (bdd:get 'axis))) ">: ")))
  (if ans (bdd:set 'axis (read (strcase ans))))

  (initget "INS BOX")
  (setq ans (getkword (strcat "\nCenter [INS/BOX] <" (strcase (vl-princ-to-string (bdd:get 'center))) ">: ")))
  (if ans (bdd:set 'center (read (strcase ans))))

  (setq ans (getreal (strcat "\nOutlier cut 0..0.45 <" (rtos (bdd:get 'cut) 2 2) ">: ")))
  (if ans (bdd:set 'cut (min 0.45 (max 0.0 ans))))

  (setq ans (getstring T (strcat "\nDimension layer <" (bdd:get 'dimlayer) ">: ")))
  (if (and ans (/= "" ans)) (bdd:set 'dimlayer ans))

  (setq ans (getstring T (strcat "\nDimStyle to use (Enter to keep current) <" (if (bdd:get 'dimstyle) (bdd:get 'dimstyle) "") ">: ")))
  (cond
    ((= ans "") (bdd:set 'dimstyle nil))
    (ans        (bdd:set 'dimstyle ans))
  )
  (prompt "\nSettings updated.")
  (princ)
)

(defun c:BDDHELP ()
  (princ
"\nBDD - dimensions between block centers:
  1) BDD     : run, select INSERTs, pick the dimension line location.
  2) BDDCFG  : edit settings: Mode, Axis, Center, Cut, DimLayer, DimStyle.
  3) BDDHELP : this help.
Mode:
  CONT  : chained dimensions between each adjacent pair.
  BASE  : baseline from the first center to all others.
Axis:
  AUTO  : picks X if horizontal spread dominates, else Y. X/Y can be forced.
Center:
  INS   : insertion point.
  BOX   : BoundingBox center (better for off-center blocks).
Cut:
  0..0.45  : ignore axis outliers by a relative cut from both ends.")
  (princ)
)
;;; =================== End of BDD v2 ===================
