;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: DBW
;;; الملف الأصلي: ‏‏cursor - نسخة (2).lsp
(defun c:DBW (/ *error* adoc
                dim_dir lay_name offset_val min_dist
                ssBlks allPts wallEnames
                dirs oldOsnap oldCmdecho undoStarted
                drawnPairs pairID
                angTol ss len
                i e ip pt ent
                neighbor p2 ent2 d_blk p_blk h_blk
                we obj ptN d_wall p_wall h_wall h1 h2 dPt
                a d_blkVal d_wallVal ang)

  (vl-load-com)
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  (setq undoStarted nil)

  (defun *error* (msg)
    (if undoStarted (vla-EndUndoMark adoc))
    (if (numberp oldOsnap) (setvar "OSMODE" oldOsnap))
    (if (numberp oldCmdecho) (setvar "CMDECHO" oldCmdecho))
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (defun DBW_SsToList (ss / lst k)
    (setq lst nil k 0)
    (if ss
      (progn
        (repeat (sslength ss)
          (setq lst (cons (ssname ss k) lst))
          (setq k (1+ k))
        )
        (reverse lst)
      )
    )
  )

  (defun DBW_RoundDeg (p1 p2 / a)
    (setq a (fix (+ 0.5 (/ (* (angle p1 p2) 180.0) pi))))
    (if (= a 360) (setq a 0))
    a
  )

  (defun DBW_AngDiff (a b / d)
    (setq d (abs (- a b)))
    (if (> d 180.0) (setq d (- 360.0 d)))
    d
  )

  ;; -------- input (بدون DCL) --------
  (initget "0 1 2")
  (setq dim_dir (getkword "\nالاتجاه المطلوب [0=كامل(X&Y)  1=أفقي(X)  2=رأسي(Y)] <0>: "))
  (if (null dim_dir) (setq dim_dir "0"))

  (setq lay_name (getstring T "\nاسم الطبقة <DIM-OFFICE>: "))
  (if (= lay_name "") (setq lay_name "DIM-OFFICE"))

  (setq offset_val (getreal "\nالإزاحة Offset <0.4>: "))
  (if (null offset_val) (setq offset_val 0.4))

  (setq min_dist (getreal "\nتجاهل أقل من Threshold <0.10>: "))
  (if (null min_dist) (setq min_dist 0.10))

  (setq angTol 5.0) ;; تساهل اتجاه (عشان يلتقط حدود أقرب)

  (vla-StartUndoMark adoc)
  (setq undoStarted T)

  (setq oldOsnap (getvar "OSMODE"))
  (setq oldCmdecho (getvar "CMDECHO"))

  (setvar "OSMODE" 0)
  (setvar "CMDECHO" 0)

  (if (not (tblsearch "LAYER" lay_name))
    (command "_-layer" "_m" lay_name "_c" "1" "" "")
  )

  (princ "\n[المكتب الفني] اختر البلوكات ثم الجدران (LINE/LWPOLYLINE/POLYLINE): ")

  (setq ssBlks (ssget "_:L" '((0 . "INSERT"))))
  (if (null ssBlks)
    (progn
      (princ "\nلم يتم اختيار بلوكات.")
      (if undoStarted (vla-EndUndoMark adoc))
      (setvar "OSMODE" oldOsnap)
      (setvar "CMDECHO" oldCmdecho)
      (princ)
    )
  )

  (setq wallEnames
    (append
      (DBW_SsToList (ssget "_:L" '((0 . "LINE"))))
      (DBW_SsToList (ssget "_:L" '((0 . "LWPOLYLINE"))))
      (DBW_SsToList (ssget "_:L" '((0 . "POLYLINE"))))
    )
  )

  (if (or (null wallEnames) (= (length wallEnames) 0))
    (progn
      (princ "\nلم يتم اختيار جدران (LINE/LWPOLYLINE/POLYLINE).")
      (if undoStarted (vla-EndUndoMark adoc))
      (if (numberp oldOsnap) (setvar "OSMODE" oldOsnap))
      (if (numberp oldCmdecho) (setvar "CMDECHO" oldCmdecho))
      (princ)
    )
  )

  ;; جمع نقاط البلوكات
  (setq allPts nil i 0)
  (repeat (sslength ssBlks)
    (setq e (ssname ssBlks i))
    (setq ip (cdr (assoc 10 (entget e))))
    (setq allPts (cons (list ip e) allPts))
    (setq i (1+ i))
  )
  (setq allPts (reverse allPts))
  (setq drawnPairs nil)

  (foreach item allPts
    (setq pt (car item))
    (setq ent (cadr item))

    (setq dirs
      (cond
        ((= dim_dir "0") '(0 90 180 270))
        ((= dim_dir "1") '(0 180))
        (t '(90 270))
      )
    )

    (foreach ang dirs
      (setq d_blk 1e10 p_blk nil h_blk nil)
      (setq d_wall 1e10 p_wall nil h_wall nil)

      ;; (أ) أقرب بلوك
      (foreach neighbor allPts
        (setq p2 (car neighbor))
        (setq ent2 (cadr neighbor))
        (if (/= ent ent2)
          (progn
            (setq d_blkVal (distance (list (car pt) (cadr pt)) (list (car p2) (cadr p2))))
            (if (> d_blkVal min_dist)
              (progn
                (setq a (DBW_RoundDeg (list (car pt) (cadr pt)) (list (car p2) (cadr p2))))
                (if (and (<= (DBW_AngDiff a ang) angTol) (< d_blkVal d_blk))
                  (setq d_blk d_blkVal p_blk p2 h_blk (cdr (assoc 5 (entget ent2))))
                )
              )
            )
          )
        )
      )

      ;; (ب) أقرب نقطة على الجدار (بدون شرط Closed حتى يلتقط بولي لاين مغلقة)
      (foreach we wallEnames
        (setq obj (vlax-ename->vla-object we))
        (setq ptN (vlax-curve-getClosestPointTo obj pt))
        (setq d_wallVal (distance (list (car pt) (cadr pt)) (list (car ptN) (cadr ptN))))
        (if (and (> d_wallVal min_dist) (< d_wallVal d_wall))
          (progn
            (setq a (DBW_RoundDeg (list (car pt) (cadr pt)) (list (car ptN) (cadr ptN))))
            (if (<= (DBW_AngDiff a ang) angTol)
              (setq d_wall d_wallVal p_wall ptN h_wall (cdr (assoc 5 (entget we))))
            )
          )
        )
      )

      ;; (ج1) بلوك مع جدار أقرب
      (if (and p_wall (< d_wall d_blk))
        (progn
          (setq pairID (strcat (cdr (assoc 5 (entget ent))) "|W|"
                               (rtos (car p_wall) 2 3) "," (rtos (cadr p_wall) 2 3)))
          (if (not (member pairID drawnPairs))
            (progn
              (setvar "CLAYER" lay_name)
              (setq dPt
                (cond
                  ((= ang 0)   (list (car pt) (+ (cadr pt) offset_val) 0))
                  ((= ang 180) (list (car pt) (- (cadr pt) offset_val) 0))
                  ((= ang 90)  (list (+ (car pt) offset_val) (cadr pt) 0))
                  ((= ang 270) (list (- (car pt) offset_val) (cadr pt) 0))
                  (t (list (car pt) (+ (cadr pt) offset_val) 0))
                )
              )
              (vl-cmdf "_.dimlinear" "_non" pt "_non" p_wall "_non" dPt)
              (setq drawnPairs (cons pairID drawnPairs))
            )
          )
        )
      )

      ;; (ج2) ربط بين البلوكات (يمين + أعلى لتقليل ازدواجية الداخلي)
      (if (and p_blk (member ang '(0 90)) (< d_blk d_wall))
        (progn
          (setq h1 (cdr (assoc 5 (entget ent))))
          (setq pairID (if (< h1 h_blk)
                          (strcat h1 "|" h_blk)
                          (strcat h_blk "|" h1)))
          (if (not (member pairID drawnPairs))
            (progn
              (setvar "CLAYER" lay_name)
              (setq dPt
                (if (= ang 0)
                  (list (car pt) (+ (cadr pt) offset_val) 0)
                  (list (+ (car pt) offset_val) (cadr pt) 0)
                )
              )
              (vl-cmdf "_.dimlinear" "_non" pt "_non" p_blk "_non" dPt)
              (setq drawnPairs (cons pairID drawnPairs))
            )
          )
        )
      )

    ) ;; foreach ang
  ) ;; foreach item

  (vla-EndUndoMark adoc)
  (if (numberp oldOsnap) (setvar "OSMODE" oldOsnap))
  (if (numberp oldCmdecho) (setvar "CMDECHO" oldCmdecho))

  (princ "\n[تم] تم إنشاء الشبكة وربط الحواف من LINE/LWPOLYLINE/POLYLINE.")
  (princ)
)