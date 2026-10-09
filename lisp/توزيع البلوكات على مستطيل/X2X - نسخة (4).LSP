;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: X2X
;;; الملف الأصلي: X2X - نسخة (4).LSP
;;; ==========================================================================
;;; أمر: X2X / ء2ء / MPAPRO (Smart Matrix Distribution & Boundary-Aware Dims)
;;; ==========================================================================

(vl-load-com)

;; متغيرات عامة لحفظ الجلسة
(setq *MPA_AppMode*   (if *MPA_AppMode*   *MPA_AppMode*   1))   ; 0: عادي | 1: كهرباء وإنارة
(setq *MPA_W*         (if *MPA_W*         *MPA_W*         6.00))
(setq *MPA_H*         (if *MPA_H*         *MPA_H*         4.00))
(setq *MPA_Area*      (if *MPA_Area*      *MPA_Area*      24.00))
(setq *MPA_PtMin*     (if *MPA_PtMin*     *MPA_PtMin*     '(0.0 0.0 0.0)))
(setq *MPA_PtMax*     (if *MPA_PtMax*     *MPA_PtMax*     '(6.0 4.0 0.0)))
(setq *MPA_Scale*     (if *MPA_Scale*     *MPA_Scale*     1.0))
(setq *MPA_Rot*       (if *MPA_Rot*       *MPA_Rot*       0.0))
(setq *MPA_Cols*      (if *MPA_Cols*      *MPA_Cols*      3))
(setq *MPA_Rows*      (if *MPA_Rows*      *MPA_Rows*      2))
(setq *MPA_ModeX*     (if *MPA_ModeX*     *MPA_ModeX*     0))   ; 0: X-2X-X | 1: X-X-X
(setq *MPA_ModeY*     (if *MPA_ModeY*     *MPA_ModeY*     0))
(setq *MPA_AddDim*    (if *MPA_AddDim*    *MPA_AddDim*    1))
(setq *MPA_DimPos*    (if *MPA_DimPos*    *MPA_DimPos*    0))   ; 0: Outside | 1: Inside
(setq *MPA_DimScope*  (if *MPA_DimScope*  *MPA_DimScope*  1))   ; 0: أول صف/عمود | 1: كامل الشبكة
(setq *MPA_AddTable*  (if *MPA_AddTable*  *MPA_AddTable*  1))
(setq *MPA_BlkIdx*    (if *MPA_BlkIdx*    *MPA_BlkIdx*    0))
(setq *MPA_DimIdx*    (if *MPA_DimIdx*    *MPA_DimIdx*    0))

;; متغيرات الإنارة
(setq *MPA_Lumens*    (if *MPA_Lumens*    *MPA_Lumens*    4000.0))
(setq *MPA_Watts*     (if *MPA_Watts*     *MPA_Watts*     40.0))
(setq *MPA_TargetLux* (if *MPA_TargetLux* *MPA_TargetLux* 500.0))
(setq *MPA_CU*        (if *MPA_CU*        *MPA_CU*        0.65))
(setq *MPA_MF*        (if *MPA_MF*        *MPA_MF*        0.80))
(setq *MPA_H_Ceil*    (if *MPA_H_Ceil*    *MPA_H_Ceil*    3.00))
(setq *MPA_H_Work*    (if *MPA_H_Work*    *MPA_H_Work*    0.80))

;; مصفوفة حدود الشكل
(setq *MPA_BoundaryPts* nil)
(setq *MPA_GeomType* "RECT") ; "RECT" | "POLY" | "CIRCLE"
(setq *MPA_CircleCenter* nil)
(setq *MPA_CircleRadius* 0.0)

(defun c:X2X_CORE ( / *error* doc spc dcl_file f dcl_id dcl_status
                      blk_list dim_list W H Area nx ny ex sx ey sy
                      calc_x calc_y calc_lux calc_grid_from_lux
                      pt_inside_p get_valid_points get_all_x_intersections get_closest_x_bounds
                      get_all_y_intersections get_closest_y_bounds
                      draw_grid_preview draw_block_preview update_all toggle_mode_ui )

  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg t) "*cancel*,*exit*")))
      (princ (strcat "\n(Error / خطأ): " msg))
    )
    (if (and dcl_file (findfile dcl_file)) (vl-file-delete dcl_file))
    (if doc (vla-endundomark doc))
    (redraw)
    (princ)
  )

  (setq doc (vla-get-activedocument (vlax-get-acad-object)))
  (setq spc (vla-get-modelspace doc))
  (vla-startundomark doc)

  ;; 1. جلب قوائم البلوكات والأبعاد
  (setq blk_list '())
  (setq blk_data (tblnext "BLOCK" t))
  (while blk_data
    (setq bname (cdr (assoc 2 blk_data)))
    (if (not (wcmatch bname "`**,*|*"))
      (setq blk_list (cons bname blk_list))
    )
    (setq blk_data (tblnext "BLOCK"))
  )
  (setq blk_list (if blk_list (acad_strlsort blk_list) (list "Standard")))
  (if (>= *MPA_BlkIdx* (length blk_list)) (setq *MPA_BlkIdx* 0))

  (setq dim_list '())
  (setq d_data (tblnext "DIMSTYLE" t))
  (while d_data
    (setq dim_list (cons (cdr (assoc 2 d_data)) dim_list))
    (setq d_data (tblnext "DIMSTYLE"))
  )
  (setq dim_list (if dim_list (acad_strlsort dim_list) (list "Standard")))
  (if (>= *MPA_DimIdx* (length dim_list)) (setq *MPA_DimIdx* 0))

  ;; 2. تهيئة المتغيرات الحسابية
  (setq W *MPA_W*  H *MPA_H*  Area *MPA_Area*
        nx *MPA_Cols*  ny *MPA_Rows*)

  (defun calc_x (mode)
    (if (<= nx 1)
      (setq ex (/ W 2.0) sx 0.0)
      (if (= mode 0)
        (setq ex (/ W (* 2.0 nx)) sx (* 2.0 ex))
        (setq ex (/ W (1+ nx))    sx ex)
      )
    )
  )

  (defun calc_y (mode)
    (if (<= ny 1)
      (setq ey (/ H 2.0) sy 0.0)
      (if (= mode 0)
        (setq ey (/ H (* 2.0 ny)) sy (* 2.0 ey))
        (setq ey (/ H (1+ ny))    sy ey)
      )
    )
  )

  ;; فحص وقوع النقطة داخل الشكل
  (defun pt_inside_p (pt / x y inside i j count p1 p2 x1 y1 x2 y2)
    (cond
      ((equal *MPA_GeomType* "CIRCLE")
       (<= (distance (list (car pt) (cadr pt)) *MPA_CircleCenter*) (+ *MPA_CircleRadius* 0.001))
      )
      ((and (equal *MPA_GeomType* "POLY") *MPA_BoundaryPts*)
       (setq x (car pt) y (cadr pt) count (length *MPA_BoundaryPts*) inside nil)
       (setq i 0 j (1- count))
       (while (< i count)
         (setq p1 (nth i *MPA_BoundaryPts*) p2 (nth j *MPA_BoundaryPts*))
         (setq x1 (car p1) y1 (cadr p1) x2 (car p2) y2 (cadr p2))
         (if (and (or (and (<= y1 y) (< y y2))
                      (and (<= y2 y) (< y y1)))
                  (< x (+ x1 (* (/ (- y y1) (if (= (- y2 y1) 0.0) 1e-6 (- y2 y1))) (- x2 x1)))))
           (setq inside (not inside))
         )
         (setq j i i (1+ i))
       )
       inside
      )
      (t t)
    )
  )

  ;; استخراج كافة تقاطعات الخط الأفقي Y مع أضلاع الشكل
  (defun get_all_x_intersections ( y_val / x_list count k p1 p2 x1 y1 x2 y2 t_val x_int dy r2 )
    (setq x_list '())
    (cond
      ((equal *MPA_GeomType* "CIRCLE")
       (setq dy (- y_val (cadr *MPA_CircleCenter*))
             r2 (- (expt *MPA_CircleRadius* 2.0) (expt dy 2.0)))
       (if (>= r2 0.0)
         (setq x_list (list (- (car *MPA_CircleCenter*) (sqrt r2))
                            (+ (car *MPA_CircleCenter*) (sqrt r2))))
       )
      )
      ((and (equal *MPA_GeomType* "POLY") *MPA_BoundaryPts*)
       (setq count (length *MPA_BoundaryPts*) k 0)
       (while (< k count)
         (setq p1 (nth k *MPA_BoundaryPts*)
               p2 (nth (rem (1+ k) count) *MPA_BoundaryPts*))
         (setq x1 (car p1) y1 (cadr p1) x2 (car p2) y2 (cadr p2))
         (if (and (or (and (<= y1 (+ y_val 1e-5)) (< y_val (- y2 1e-5)))
                      (and (<= y2 (+ y_val 1e-5)) (< y_val (- y1 1e-5))))
                  (> (abs (- y2 y1)) 1e-6))
           (progn
             (setq t_val (/ (- y_val y1) (- y2 y1)))
             (if (and (>= t_val -1e-5) (<= t_val 1.00001))
               (setq x_int (+ x1 (* t_val (- x2 x1)))
                     x_list (cons x_int x_list))
             )
           )
         )
         (setq k (1+ k))
       )
      )
      (t
       (setq x_list (list (car *MPA_PtMin*) (car *MPA_PtMax*)))
      )
    )
    (if (null x_list) (setq x_list (list (car *MPA_PtMin*) (car *MPA_PtMax*))))
    x_list
  )

  ;; استخراج الضلع الأقرب يساراً ويميناً بالنسبة لعناصر الصف
  (defun get_closest_x_bounds ( y_val min_blk_x max_blk_x / all_x left_cand right_cand l_bound r_bound )
    (setq all_x (get_all_x_intersections y_val))
    (setq left_cand '())
    (foreach x all_x
      (if (<= x (+ min_blk_x 1e-3))
        (setq left_cand (cons x left_cand))
      )
    )
    (setq l_bound (if left_cand (apply 'max left_cand) (apply 'min all_x)))

    (setq right_cand '())
    (foreach x all_x
      (if (>= x (- max_blk_x 1e-3))
        (setq right_cand (cons x right_cand))
      )
    )
    (setq r_bound (if right_cand (apply 'min right_cand) (apply 'max all_x)))
    (list l_bound r_bound)
  )

  ;; استخراج كافة تقاطعات الخط الرأسي X مع أضلاع الشكل
  (defun get_all_y_intersections ( x_val / y_list count k p1 p2 x1 y1 x2 y2 t_val y_int dx r2 )
    (setq y_list '())
    (cond
      ((equal *MPA_GeomType* "CIRCLE")
       (setq dx (- x_val (car *MPA_CircleCenter*))
             r2 (- (expt *MPA_CircleRadius* 2.0) (expt dx 2.0)))
       (if (>= r2 0.0)
         (setq y_list (list (- (cadr *MPA_CircleCenter*) (sqrt r2))
                            (+ (cadr *MPA_CircleCenter*) (sqrt r2))))
       )
      )
      ((and (equal *MPA_GeomType* "POLY") *MPA_BoundaryPts*)
       (setq count (length *MPA_BoundaryPts*) k 0)
       (while (< k count)
         (setq p1 (nth k *MPA_BoundaryPts*)
               p2 (nth (rem (1+ k) count) *MPA_BoundaryPts*))
         (setq x1 (car p1) y1 (cadr p1) x2 (car p2) y2 (cadr p2))
         (if (and (or (and (<= x1 (+ x_val 1e-5)) (< x_val (- x2 1e-5)))
                      (and (<= x2 (+ x_val 1e-5)) (< x_val (- x1 1e-5))))
                  (> (abs (- x2 x1)) 1e-6))
           (progn
             (setq t_val (/ (- x_val x1) (- x2 x1)))
             (if (and (>= t_val -1e-5) (<= t_val 1.00001))
               (setq y_int (+ y1 (* t_val (- y2 y1)))
                     y_list (cons y_int y_list))
             )
           )
         )
         (setq k (1+ k))
       )
      )
      (t
       (setq y_list (list (cadr *MPA_PtMin*) (cadr *MPA_PtMax*)))
      )
    )
    (if (null y_list) (setq y_list (list (cadr *MPA_PtMin*) (cadr *MPA_PtMax*))))
    y_list
  )

  ;; استخراج الضلع الأقرب أسفلاً وأعلى بالنسبة لعناصر العمود
  (defun get_closest_y_bounds ( x_val min_blk_y max_blk_y / all_y bot_cand top_cand b_bound t_bound )
    (setq all_y (get_all_y_intersections x_val))
    (setq bot_cand '())
    (foreach y all_y
      (if (<= y (+ min_blk_y 1e-3))
        (setq bot_cand (cons y bot_cand))
      )
    )
    (setq b_bound (if bot_cand (apply 'max bot_cand) (apply 'min all_y)))

    (setq top_cand '())
    (foreach y all_y
      (if (>= y (- max_blk_y 1e-3))
        (setq top_cand (cons y top_cand))
      )
    )
    (setq t_bound (if top_cand (apply 'min top_cand) (apply 'max all_y)))
    (list b_bound t_bound)
  )

  ;; استخراج النقاط الصحيحة داخل الشكل
  (defun get_valid_points ( / valid i j px py pt )
    (setq valid '() i 0)
    (while (< i nx)
      (setq j 0)
      (while (< j ny)
        (setq px (+ (car *MPA_PtMin*) ex (* i sx))
              py (+ (cadr *MPA_PtMin*) ey (* j sy))
              pt (list px py 0.0))
        (if (pt_inside_p pt)
          (setq valid (cons (list i j pt) valid))
        )
        (setq j (1+ j))
      )
      (setq i (1+ i))
    )
    (reverse valid)
  )

  ;; حسابات الإنارة
  (defun calc_lux ( / valid_cnt total_flux act_lux w_per_m2 k_idx hm )
    (setq valid_cnt (length (get_valid_points)))
    (setq total_flux (* valid_cnt *MPA_Lumens* *MPA_CU* *MPA_MF*))
    (setq act_lux (if (> Area 0.001) (/ total_flux Area) 0.0))
    (setq w_per_m2 (if (> Area 0.001) (/ (* valid_cnt *MPA_Watts*) Area) 0.0))
    (setq hm (max 0.1 (- *MPA_H_Ceil* *MPA_H_Work*)))
    (setq k_idx (if (> (+ W H) 0.001) (/ (* W H) (* hm (+ W H))) 0.0))
    (list act_lux w_per_m2 k_idx valid_cnt)
  )

  (defun calc_grid_from_lux ( / req_flux req_n ratio opt_nx opt_ny )
    (setq req_flux (/ (* *MPA_TargetLux* Area) (* *MPA_CU* *MPA_MF*)))
    (setq req_n (max 1 (fix (+ 0.5 (/ req_flux *MPA_Lumens*)))))
    (setq ratio (if (> H 0.001) (/ W H) 1.0))
    (setq opt_ny (max 1 (fix (+ 0.5 (sqrt (/ req_n ratio))))))
    (setq opt_nx (max 1 (fix (+ 0.5 (/ (float req_n) opt_ny)))))
    (setq nx opt_nx ny opt_ny *MPA_Cols* nx *MPA_Rows* ny)
    (calc_x *MPA_ModeX*)
    (calc_y *MPA_ModeY*)
  )

  (calc_x *MPA_ModeX*)
  (calc_y *MPA_ModeY*)

  ;; 3. المعاينة الرسومية
  (defun draw_grid_preview ( / img_w img_h sc ox oy margin i j px py k p1 p2 a da cx cy cr pt )
    (setq img_w (dimx_tile "prev_img")
          img_h (dimy_tile "prev_img")
          margin 16)
    (start_image "prev_img")
    (fill_image 0 0 img_w img_h 0)

    (setq sc (min (/ (- img_w (* 2 margin)) (max 0.01 W))
                  (/ (- img_h (* 2 margin)) (max 0.01 H))))
    (setq ox (/ (- img_w (* W sc)) 2.0)
          oy (/ (- img_h (* H sc)) 2.0))

    ;; رسم الإطار المرجعي
    (vector_image (fix ox) (fix oy) (fix (+ ox (* W sc))) (fix oy) 8)
    (vector_image (fix (+ ox (* W sc))) (fix oy) (fix (+ ox (* W sc))) (fix (+ oy (* H sc))) 8)
    (vector_image (fix (+ ox (* W sc))) (fix (+ oy (* H sc))) (fix ox) (fix (+ oy (* H sc))) 8)
    (vector_image (fix ox) (fix (+ oy (* H sc))) (fix ox) (fix oy) 8)

    ;; رسم محيط الشكل
    (cond
      ((equal *MPA_GeomType* "CIRCLE")
       (setq a 0.0 da (/ (* 2 pi) 32.0)
             cx (+ ox (* (- (car *MPA_CircleCenter*) (car *MPA_PtMin*)) sc))
             cy (- (+ oy (* H sc)) (* (- (cadr *MPA_CircleCenter*) (cadr *MPA_PtMin*)) sc))
             cr (* *MPA_CircleRadius* sc))
       (repeat 32
         (vector_image (fix (+ cx (* cr (cos a)))) (fix (+ cy (* cr (sin a))))
                       (fix (+ cx (* cr (cos (+ a da))))) (fix (+ cy (* cr (sin (+ a da))))) 7)
         (setq a (+ a da))
       )
      )
      ((and (equal *MPA_GeomType* "POLY") *MPA_BoundaryPts*)
       (setq k 0 count (length *MPA_BoundaryPts*))
       (while (< k count)
         (setq p1 (nth k *MPA_BoundaryPts*)
               p2 (nth (rem (1+ k) count) *MPA_BoundaryPts*))
         (vector_image (fix (+ ox (* (- (car p1) (car *MPA_PtMin*)) sc)))
                       (fix (- (+ oy (* H sc)) (* (- (cadr p1) (cadr *MPA_PtMin*)) sc)))
                       (fix (+ ox (* (- (car p2) (car *MPA_PtMin*)) sc)))
                       (fix (- (+ oy (* H sc)) (* (- (cadr p2) (cadr *MPA_PtMin*)) sc)))
                       7)
         (setq k (1+ k))
       )
      )
    )

    ;; رسم الكشافات
    (setq i 0)
    (while (< i nx)
      (setq j 0)
      (while (< j ny)
        (setq px (+ ox (* (+ ex (* i sx)) sc))
              py (- (+ oy (* H sc)) (* (+ ey (* j sy)) sc))
              pt (list (+ (car *MPA_PtMin*) ex (* i sx)) (+ (cadr *MPA_PtMin*) ey (* j sy)) 0.0))
        (if (pt_inside_p pt)
          (progn
            (vector_image (fix (- px 4)) (fix py) (fix (+ px 4)) (fix py) 3)
            (vector_image (fix px) (fix (- py 4)) (fix px) (fix (+ py 4)) 3)
          )
          (progn
            (vector_image (fix (- px 3)) (fix (- py 3)) (fix (+ px 3)) (fix (+ py 3)) 1)
            (vector_image (fix (- px 3)) (fix (+ py 3)) (fix (+ px 3)) (fix (- py 3)) 1)
          )
        )
        (setq j (1+ j))
      )
      (setq i (1+ i))
    )
    (end_image)
  )

  ;; 4. معاينة البلوك
  (defun draw_block_preview ( bname / img_w img_h ent sub ed e_type lines pts minx miny maxx maxy bw bh sc ox oy )
    (setq img_w (dimx_tile "blk_img")
          img_h (dimy_tile "blk_img"))
    (start_image "blk_img")
    (fill_image 0 0 img_w img_h 0)

    (setq ent (tblobjname "BLOCK" bname))
    (if ent
      (progn
        (setq sub (entnext ent) lines '() pts '())
        (while sub
          (setq ed (entget sub) e_type (cdr (assoc 0 ed)))
          (cond
            ((= e_type "LINE")
             (setq p1 (cdr (assoc 10 ed)) p2 (cdr (assoc 11 ed)))
             (setq lines (cons (list (car p1) (cadr p1) (car p2) (cadr p2)) lines))
             (setq pts (cons (list (car p1) (cadr p1)) (cons (list (car p2) (cadr p2)) pts))))
            ((= e_type "CIRCLE")
             (setq cp (cdr (assoc 10 ed)) r (cdr (assoc 40 ed)) a 0.0 da (/ (* 2 pi) 16.0))
             (repeat 16
               (setq p1 (list (+ (car cp) (* r (cos a))) (+ (cadr cp) (* r (sin a))))
                     p2 (list (+ (car cp) (* r (cos (+ a da)))) (+ (cadr cp) (* r (sin (+ a da))))))
               (setq lines (cons (list (car p1) (cadr p1) (car p2) (cadr p2)) lines))
               (setq pts (cons p1 pts))
               (setq a (+ a da))
             ))
            ((= e_type "ARC")
             (setq cp (cdr (assoc 10 ed)) r (cdr (assoc 40 ed))
                   sa (cdr (assoc 50 ed)) ea (cdr (assoc 51 ed)))
             (if (< ea sa) (setq ea (+ ea (* 2 pi))))
             (setq da (/ (- ea sa) 10.0) a sa)
             (repeat 10
               (setq p1 (list (+ (car cp) (* r (cos a))) (+ (cadr cp) (* r (sin a))))
                     p2 (list (+ (car cp) (* r (cos (+ a da)))) (+ (cadr cp) (* r (sin (+ a da))))))
               (setq lines (cons (list (car p1) (cadr p1) (car p2) (cadr p2)) lines))
               (setq pts (cons p1 pts))
               (setq a (+ a da))
             ))
            ((= e_type "LWPOLYLINE")
             (setq v_pts '())
             (foreach x ed (if (= (car x) 10) (setq v_pts (cons (cdr x) v_pts))))
             (setq v_pts (reverse v_pts))
             (setq k 0)
             (while (< k (1- (length v_pts)))
               (setq p1 (nth k v_pts) p2 (nth (1+ k) v_pts))
               (setq lines (cons (list (car p1) (cadr p1) (car p2) (cadr p2)) lines))
               (setq pts (cons p1 (cons p2 pts)))
               (setq k (1+ k))
             )
             (if (= 1 (logand 1 (cdr (assoc 70 ed))))
               (progn
                 (setq p1 (last v_pts) p2 (car v_pts))
                 (setq lines (cons (list (car p1) (cadr p1) (car p2) (cadr p2)) lines))
                 (setq pts (cons p1 (cons p2 pts)))
               )
             ))
          )
          (setq sub (entnext sub))
        )
        (if pts
          (progn
            (setq minx (apply 'min (mapcar 'car pts)) maxx (apply 'max (mapcar 'car pts))
                  miny (apply 'min (mapcar 'cadr pts)) maxy (apply 'max (mapcar 'cadr pts))
                  bw (max 0.0001 (- maxx minx)) bh (max 0.0001 (- maxy miny))
                  sc (min (/ (- img_w 12) bw) (/ (- img_h 12) bh))
                  ox (/ (- img_w (* bw sc)) 2.0) oy (/ (- img_h (* bh sc)) 2.0))
            (foreach ln lines
              (vector_image
                (fix (+ ox (* (- (nth 0 ln) minx) sc)))
                (fix (- (+ oy (* bh sc)) (* (- (nth 1 ln) miny) sc)))
                (fix (+ ox (* (- (nth 2 ln) minx) sc)))
                (fix (- (+ oy (* bh sc)) (* (- (nth 3 ln) miny) sc)))
                3
              )
            )
          )
          (progn
            (vector_image 10 10 (- img_w 10) (- img_h 10) 8)
            (vector_image 10 (- img_h 10) (- img_w 10) 10 8)
          )
        )
      )
    )
    (end_image)
  )

  (defun toggle_mode_ui ()
    (if (= *MPA_AppMode* 1)
      (progn
        (mode_tile "eb_target_lux" 0) (mode_tile "eb_lumens" 0) (mode_tile "eb_watts" 0)
        (mode_tile "eb_h_ceil" 0) (mode_tile "eb_h_work" 0) (mode_tile "eb_cu" 0)
        (mode_tile "eb_mf" 0) (mode_tile "btn_auto_lux" 0) (mode_tile "tog_table" 0)
      )
      (progn
        (mode_tile "eb_target_lux" 1) (mode_tile "eb_lumens" 1) (mode_tile "eb_watts" 1)
        (mode_tile "eb_h_ceil" 1) (mode_tile "eb_h_work" 1) (mode_tile "eb_cu" 1)
        (mode_tile "eb_mf" 1) (mode_tile "btn_auto_lux" 1) (mode_tile "tog_table" 1)
      )
    )
  )

  (defun update_all ( / lux_res )
    (setq lux_res (calc_lux))
    (set_tile "txt_w_val" (strcat "Width (W): " (rtos W 2 2) " m"))
    (set_tile "txt_h_val" (strcat "Length (L): " (rtos H 2 2) " m"))
    (set_tile "txt_area_val" (strcat "Area (المساحة): " (rtos Area 2 2) " m²"))
    
    (set_tile "txt_ex_top" (strcat "Edge X: " (rtos ex 2 3)))
    (set_tile "txt_sx_top" (strcat "Span X: " (rtos sx 2 3)))
    (set_tile "txt_ey_side" (strcat "Edge Y: " (rtos ey 2 3)))
    (set_tile "txt_sy_side" (strcat "Span Y: " (rtos sy 2 3)))

    (set_tile "eb_nx" (itoa nx))
    (set_tile "eb_ny" (itoa ny))
    (set_tile "eb_ex" (rtos ex 2 3))
    (set_tile "eb_sx" (rtos sx 2 3))
    (set_tile "eb_ey" (rtos ey 2 3))
    (set_tile "eb_sy" (rtos sy 2 3))

    (if (= *MPA_AppMode* 1)
      (progn
        (set_tile "txt_lux_calc" (strcat "Calculated Lux (اللوكس): " (rtos (nth 0 lux_res) 2 1) " Lux"))
        (set_tile "txt_pwr_calc" (strcat "Power Density (القدرة): " (rtos (nth 1 lux_res) 2 2) " W/m²"))
        (set_tile "txt_k_calc"   (strcat "Room Index (K): " (rtos (nth 2 lux_res) 2 2)))
        (set_tile "txt_qty_calc" (strcat "Valid Units (المعتمد): " (itoa (nth 3 lux_res)) " Pcs"))
      )
      (progn
        (set_tile "txt_lux_calc" "وضع التوزيع القياسي (Standard Mode)")
        (set_tile "txt_pwr_calc" "حسابات الإنارة معطلة")
        (set_tile "txt_k_calc"   "-")
        (set_tile "txt_qty_calc" (strcat "Valid Units (المعتمد): " (itoa (nth 3 lux_res)) " Pcs"))
      )
    )

    (draw_grid_preview)
    (if (< *MPA_BlkIdx* (length blk_list))
      (draw_block_preview (nth *MPA_BlkIdx* blk_list))
    )
    (toggle_mode_ui)
  )

  ;; 5. ملف DCL
  (setq dcl_file (vl-filename-mktemp "x2x_pro.dcl"))
  (setq f (open dcl_file "w"))
  (write-line "x2x_pro_dlg : dialog { label = \"X2X Pro: Universal Matrix & Lighting Engine\";" f)
  (write-line "  : boxed_row { label = \"System Workflow Mode (نمط التطبيق)\";" f)
  (write-line "    : popup_list { key = \"pop_app_mode\"; label = \"نوع التوزيع:\"; width = 35; }" f)
  (write-line "  }" f)
  (write-line "  : row {" f)
  (write-line "    : boxed_column { label = \"Boundary & Real-Shape Preview (المعاينة الحية)\";" f)
  (write-line "      : row {" f)
  (write-line "        : text { key = \"txt_ex_top\"; width = 16; alignment = centered; }" f)
  (write-line "        : text { key = \"txt_sx_top\"; width = 16; alignment = centered; }" f)
  (write-line "      }" f)
  (write-line "      : row {" f)
  (write-line "        : column {" f)
  (write-line "          : text { key = \"txt_ey_side\"; alignment = centered; }" f)
  (write-line "          : text { key = \"txt_sy_side\"; alignment = centered; }" f)
  (write-line "        }" f)
  (write-line "        : image { key = \"prev_img\"; width = 58; height = 15; color = 0; }" f)
  (write-line "      }" f)
  (write-line "      : row {" f)
  (write-line "        : text { key = \"txt_w_val\"; width = 18; }" f)
  (write-line "        : text { key = \"txt_h_val\"; width = 18; }" f)
  (write-line "        : text { key = \"txt_area_val\"; width = 20; }" f)
  (write-line "      }" f)
  (write-line "      : button { key = \"btn_pick_geom\"; label = \"⛶ Pick Boundary (دائرة / مضلع / شكل غير منتظم / مستطيل)\"; width = 34; }" f)
  (write-line "    }" f)
  (write-line "    : column {" f)
  (write-line "      : boxed_column { label = \"Electrical & Lighting Engine (حسابات الإنارة واللوكس)\";" f)
  (write-line "        : row {" f)
  (write-line "          : edit_box { key = \"eb_target_lux\"; label = \"Target (اللوكس): \"; edit_width = 6; }" f)
  (write-line "          : edit_box { key = \"eb_lumens\"; label = \"Lumens: \"; edit_width = 6; }" f)
  (write-line "          : edit_box { key = \"eb_watts\"; label = \"Watts: \"; edit_width = 5; }" f)
  (write-line "        }" f)
  (write-line "        : row {" f)
  (write-line "          : edit_box { key = \"eb_h_ceil\"; label = \"Ceiling H: \"; edit_width = 5; }" f)
  (write-line "          : edit_box { key = \"eb_h_work\"; label = \"Work H: \"; edit_width = 5; }" f)
  (write-line "          : edit_box { key = \"eb_cu\"; label = \"CU: \"; edit_width = 4; }" f)
  (write-line "          : edit_box { key = \"eb_mf\"; label = \"MF: \"; edit_width = 4; }" f)
  (write-line "        }" f)
  (write-line "        : row {" f)
  (write-line "          : button { key = \"btn_auto_lux\"; label = \"⚡ Auto Grid Calculation (توزيع تلقائي)\"; width = 24; }" f)
  (write-line "          : column {" f)
  (write-line "            : text { key = \"txt_lux_calc\"; }" f)
  (write-line "            : text { key = \"txt_pwr_calc\"; }" f)
  (write-line "          }" f)
  (write-line "        }" f)
  (write-line "        : row {" f)
  (write-line "          : text { key = \"txt_k_calc\"; width = 22; }" f)
  (write-line "          : text { key = \"txt_qty_calc\"; width = 26; }" f)
  (write-line "        }" f)
  (write-line "      }" f)
  (write-line "      : boxed_column { label = \"Block & Matrix Distribution (البلوك والمصفوفة)\";" f)
  (write-line "        : row {" f)
  (write-line "          : column {" f)
  (write-line "            : popup_list { key = \"pop_blk\"; label = \"Block Name:\"; width = 18; }" f)
  (write-line "            : button { key = \"btn_pick_blk\"; label = \"⌖ Pick from Model\"; width = 18; }" f)
  (write-line "            : row {" f)
  (write-line "              : edit_box { key = \"eb_scale\"; label = \"Scale:\"; edit_width = 5; }" f)
  (write-line "              : edit_box { key = \"eb_rot\";   label = \"Rot (°):\"; edit_width = 5; }" f)
  (write-line "            }" f)
  (write-line "          }" f)
  (write-line "          : image { key = \"blk_img\"; width = 16; height = 5; color = 0; }" f)
  (write-line "        }" f)
  (write-line "        : row {" f)
  (write-line "          : edit_box { key = \"eb_nx\"; label = \"Cols (X):\"; edit_width = 5; }" f)
  (write-line "          : edit_box { key = \"eb_ny\"; label = \"Rows (Y):\"; edit_width = 5; }" f)
  (write-line "          : popup_list { key = \"pop_mode_x\"; label = \"X Pattern:\"; width = 15; }" f)
  (write-line "          : popup_list { key = \"pop_mode_y\"; label = \"Y Pattern:\"; width = 15; }" f)
  (write-line "        }" f)
  (write-line "        : row {" f)
  (write-line "          : edit_box { key = \"eb_ex\"; label = \"Edge X:\"; edit_width = 6; }" f)
  (write-line "          : edit_box { key = \"eb_sx\"; label = \"Span X:\"; edit_width = 6; }" f)
  (write-line "          : edit_box { key = \"eb_ey\"; label = \"Edge Y:\"; edit_width = 6; }" f)
  (write-line "          : edit_box { key = \"eb_sy\"; label = \"Span Y:\"; edit_width = 6; }" f)
  (write-line "        }" f)
  (write-line "      }" f)
  (write-line "      : boxed_column { label = \"CAD Dimensions & Report (الأبعاد والجدول الهندسي)\";" f)
  (write-line "        : row {" f)
  (write-line "          : toggle { key = \"tog_dim\"; label = \"Add Dimensions (إدراج الأبعاد)\"; }" f)
  (write-line "          : toggle { key = \"tog_table\"; label = \"Add Stamp Outside (تقرير هندسي)\"; }" f)
  (write-line "        }" f)
  (write-line "        : row {" f)
  (write-line "          : popup_list { key = \"pop_dimstyle\"; label = \"Dim Style:\"; width = 16; }" f)
  (write-line "          : popup_list { key = \"pop_dimpos\"; label = \"الموضع:\"; width = 14; }" f)
  (write-line "          : popup_list { key = \"pop_dimscope\"; label = \"النطاق:\"; width = 14; }" f)
  (write-line "        }" f)
  (write-line "      }" f)
  (write-line "    }" f)
  (write-line "  }" f)
  (write-line "  ok_cancel;" f)
  (write-line "}" f)
  (close f)

  ;; 6. حلقة التفاعل
  (setq dcl_status 99)
  (while (> dcl_status 1)
    (setq dcl_id (load_dialog dcl_file))
    (if (not (new_dialog "x2x_pro_dlg" dcl_id)) (exit))

    (start_list "pop_app_mode")
    (add_list "توزيع كهرباء وإنارة (Electrical & Lighting)")
    (add_list "توزيع قياسي عام (Standard Distribution)")
    (end_list)
    (set_tile "pop_app_mode" (if (= *MPA_AppMode* 1) "0" "1"))

    (start_list "pop_blk")
    (mapcar 'add_list blk_list)
    (end_list)
    (set_tile "pop_blk" (itoa *MPA_BlkIdx*))

    (start_list "pop_dimstyle")
    (mapcar 'add_list dim_list)
    (end_list)
    (set_tile "pop_dimstyle" (itoa *MPA_DimIdx*))

    (start_list "pop_dimpos")
    (add_list "خارج المستطيل (Outside)")
    (add_list "داخل المستطيل (Inside)")
    (end_list)
    (set_tile "pop_dimpos" (itoa *MPA_DimPos*))

    (start_list "pop_dimscope")
    (add_list "أول صف وعمود فقط")
    (add_list "كامل الشبكة (بالكل)")
    (end_list)
    (set_tile "pop_dimscope" (itoa *MPA_DimScope*))

    (start_list "pop_mode_x")
    (add_list "X - 2X - 2X - X")
    (add_list "X - X - X - X")
    (end_list)
    (set_tile "pop_mode_x" (itoa *MPA_ModeX*))

    (start_list "pop_mode_y")
    (add_list "Y - 2Y - 2Y - Y")
    (add_list "Y - Y - Y - Y")
    (end_list)
    (set_tile "pop_mode_y" (itoa *MPA_ModeY*))

    (set_tile "eb_target_lux" (rtos *MPA_TargetLux* 2 0))
    (set_tile "eb_lumens"     (rtos *MPA_Lumens* 2 0))
    (set_tile "eb_watts"      (rtos *MPA_Watts* 2 1))
    (set_tile "eb_h_ceil"     (rtos *MPA_H_Ceil* 2 2))
    (set_tile "eb_h_work"     (rtos *MPA_H_Work* 2 2))
    (set_tile "eb_cu"         (rtos *MPA_CU* 2 2))
    (set_tile "eb_mf"         (rtos *MPA_MF* 2 2))

    (set_tile "eb_scale" (rtos *MPA_Scale* 2 2))
    (set_tile "eb_rot"   (rtos *MPA_Rot* 2 2))
    (set_tile "tog_dim"  (itoa *MPA_AddDim*))
    (set_tile "tog_table" (itoa *MPA_AddTable*))

    (update_all)

    (action_tile "pop_app_mode"
      "(if (= $value \"0\") (setq *MPA_AppMode* 1) (setq *MPA_AppMode* 0)) (update_all)")

    (action_tile "pop_blk"
      "(setq *MPA_BlkIdx* (atoi $value)) (draw_block_preview (nth *MPA_BlkIdx* blk_list))")

    (action_tile "pop_dimstyle"  "(setq *MPA_DimIdx* (atoi $value))")
    (action_tile "pop_dimpos"    "(setq *MPA_DimPos* (atoi $value))")
    (action_tile "pop_dimscope"  "(setq *MPA_DimScope* (atoi $value))")
    (action_tile "tog_dim"       "(setq *MPA_AddDim* (atoi $value))")
    (action_tile "tog_table"     "(setq *MPA_AddTable* (atoi $value))")

    (action_tile "eb_target_lux" "(setq *MPA_TargetLux* (atof $value)) (update_all)")
    (action_tile "eb_lumens"     "(setq *MPA_Lumens* (atof $value)) (update_all)")
    (action_tile "eb_watts"      "(setq *MPA_Watts* (atof $value)) (update_all)")
    (action_tile "eb_h_ceil"     "(setq *MPA_H_Ceil* (atof $value)) (update_all)")
    (action_tile "eb_h_work"     "(setq *MPA_H_Work* (atof $value)) (update_all)")
    (action_tile "eb_cu"         "(setq *MPA_CU* (atof $value)) (update_all)")
    (action_tile "eb_mf"         "(setq *MPA_MF* (atof $value)) (update_all)")

    (action_tile "btn_auto_lux"  "(calc_grid_from_lux) (update_all)")

    (action_tile "pop_mode_x"
      "(setq *MPA_ModeX* (atoi $value)) (calc_x *MPA_ModeX*) (update_all)")

    (action_tile "pop_mode_y"
      "(setq *MPA_ModeY* (atoi $value)) (calc_y *MPA_ModeY*) (update_all)")

    (action_tile "eb_nx"
      "(setq nx (max 1 (atoi $value))) (setq *MPA_Cols* nx) (calc_x *MPA_ModeX*) (update_all)")

    (action_tile "eb_ny"
      "(setq ny (max 1 (atoi $value))) (setq *MPA_Rows* ny) (calc_y *MPA_ModeY*) (update_all)")

    (action_tile "eb_ex"
      "(setq ex (atof $value))
       (if (> nx 1) (setq sx (/ (- W (* 2.0 ex)) (1- nx))) (setq sx 0.0))
       (update_all)")

    (action_tile "eb_sx"
      "(setq sx (atof $value))
       (if (> nx 1) (setq ex (/ (- W (* (1- nx) sx)) 2.0)))
       (update_all)")

    (action_tile "eb_ey"
      "(setq ey (atof $value))
       (if (> ny 1) (setq sy (/ (- H (* 2.0 ey)) (1- ny))) (setq sy 0.0))
       (update_all)")

    (action_tile "eb_sy"
      "(setq sy (atof $value))
       (if (> ny 1) (setq ey (/ (- H (* (1- ny) sy)) 2.0)))
       (update_all)")

    (action_tile "btn_pick_geom" "(done_dialog 2)")
    (action_tile "btn_pick_blk"  "(done_dialog 3)")

    (action_tile "accept"
      "(setq *MPA_Scale* (atof (get_tile \"eb_scale\"))
             *MPA_Rot*   (atof (get_tile \"eb_rot\"))
             *MPA_AddDim* (atoi (get_tile \"tog_dim\"))
             *MPA_AddTable* (atoi (get_tile \"tog_table\")))
       (done_dialog 1)")

    (action_tile "cancel" "(done_dialog 0)")

    (setq dcl_status (start_dialog))
    (unload_dialog dcl_id)

    ;; التقاط الأشكال
    (cond
      ((= dcl_status 2)
       (setvar "CMDECHO" 0)
       (setq ent (entsel "\nاختر الشكل (Polyline / Circle / Rectangle) أو بالفراغ لتحديد نقطتين: "))
       (if ent
         (progn
           (setq obj_geom (vlax-ename->vla-object (car ent))
                 ed (entget (car ent))
                 e_type (cdr (assoc 0 ed)))
           (vla-getboundingbox obj_geom 'min_pt 'max_pt)
           (setq *MPA_PtMin* (vlax-safearray->list min_pt)
                 *MPA_PtMax* (vlax-safearray->list max_pt))

           (cond
             ((= e_type "CIRCLE")
              (setq *MPA_GeomType* "CIRCLE"
                    *MPA_CircleCenter* (cdr (assoc 10 ed))
                    *MPA_CircleRadius* (cdr (assoc 40 ed))
                    *MPA_Area* (* pi (expt *MPA_CircleRadius* 2.0)))
             )
             ((= e_type "LWPOLYLINE")
              (setq *MPA_GeomType* "POLY"
                    *MPA_BoundaryPts* '())
              (foreach x ed
                (if (= (car x) 10)
                  (setq *MPA_BoundaryPts* (cons (cdr x) *MPA_BoundaryPts*))
                )
              )
              (setq *MPA_BoundaryPts* (reverse *MPA_BoundaryPts*))
              (if (vlax-property-available-p obj_geom 'Area)
                (setq *MPA_Area* (vla-get-area obj_geom))
                (setq *MPA_Area* (* (- (car *MPA_PtMax*) (car *MPA_PtMin*)) (- (cadr *MPA_PtMax*) (cadr *MPA_PtMin*))))
              )
             )
             (t
              (setq *MPA_GeomType* "RECT" *MPA_BoundaryPts* nil)
              (if (vlax-property-available-p obj_geom 'Area)
                (setq *MPA_Area* (vla-get-area obj_geom))
                (setq *MPA_Area* (* (- (car *MPA_PtMax*) (car *MPA_PtMin*)) (- (cadr *MPA_PtMax*) (cadr *MPA_PtMin*))))
              )
             )
           )
         )
         (progn
           (setq p1 (getpoint "\nحدد الركن الأول (First Corner): "))
           (if p1
             (progn
               (setq p2 (getcorner p1 "\nحدد الركن المقابل (Opposite Corner): "))
               (if p2
                 (progn
                   (setq *MPA_PtMin* (list (min (car p1) (car p2)) (min (cadr p1) (cadr p2)) 0.0)
                         *MPA_PtMax* (list (max (car p1) (car p2)) (max (cadr p1) (cadr p2)) 0.0)
                         *MPA_GeomType* "RECT"
                         *MPA_BoundaryPts* nil
                         *MPA_Area* (* (- (car *MPA_PtMax*) (car *MPA_PtMin*)) (- (cadr *MPA_PtMax*) (cadr *MPA_PtMin*))))
                 )
               )
             )
           )
         )
       )
       (setq W (max 0.001 (- (car *MPA_PtMax*) (car *MPA_PtMin*)))
             H (max 0.001 (- (cadr *MPA_PtMax*) (cadr *MPA_PtMin*)))
             Area *MPA_Area*
             *MPA_W* W *MPA_H* H)
       (calc_x *MPA_ModeX*)
       (calc_y *MPA_ModeY*)
       (setq dcl_status 99)
      )

      ((= dcl_status 3)
       (setq ent (car (entsel "\nاختر البلوك المطلوب من الرسم: ")))
       (if ent
         (progn
           (setq bname (vla-get-effectivename (vlax-ename->vla-object ent)))
           (setq idx (vl-position bname blk_list))
           (if idx (setq *MPA_BlkIdx* idx))
         )
       )
       (setq dcl_status 99)
      )
    )
  )

  (if (findfile dcl_file) (vl-file-delete dcl_file))

  ;; 7. التنفيذ النهائي
  (if (= dcl_status 1)
    (progn
      (setq cur_blk (nth *MPA_BlkIdx* blk_list))
      (setq cur_dim (nth *MPA_DimIdx* dim_list))
      (setq valid_items (get_valid_points))
      (setq lux_res (calc_lux))

      ;; إدراج البلوكات
      (foreach item valid_items
        (setq ins_pt (vlax-3d-point (nth 2 item)))
        (vla-insertblock spc ins_pt cur_blk *MPA_Scale* *MPA_Scale* *MPA_Scale* (* *MPA_Rot* (/ pi 180.0)))
      )

      ;; رسم الأبعاد الذكية من الأضلاع الأقرب
      (if (= *MPA_AddDim* 1)
        (progn
          (setq off_d (/ (max W H) 20.0))

          (defun safe_add_dim (p1 p2 ptext rot / dim_obj)
            (if (> (distance p1 p2) 0.001)
              (progn
                (setq dim_obj (vla-adddimrotated spc (vlax-3d-point p1) (vlax-3d-point p2) (vlax-3d-point ptext) rot))
                (vl-catch-all-apply 'vla-put-stylename (list dim_obj cur_dim))
                dim_obj
              )
            )
          )

          ;; أبعاد المحور الأفقي (X)
          (setq active_j_list '())
          (foreach item valid_items
            (if (not (member (cadr item) active_j_list))
              (setq active_j_list (cons (cadr item) active_j_list))
            )
          )
          (setq active_j_list (vl-sort active_j_list '<))

          (setq rows_to_dim (if (= *MPA_DimScope* 0) (list (car active_j_list)) active_j_list))
          (setq r_idx 0)

          (foreach curr_j rows_to_dim
            (if curr_j
              (progn
                (setq cur_y (+ (cadr *MPA_PtMin*) ey (* curr_j sy)))
                (setq row_x_pts '())
                (foreach item valid_items
                  (if (= (cadr item) curr_j)
                    (setq row_x_pts (cons (car (nth 2 item)) row_x_pts))
                  )
                )
                (setq row_x_pts (vl-sort row_x_pts '<))

                (if row_x_pts
                  (progn
                    (setq min_x (car row_x_pts)
                          max_x (last row_x_pts))
                    ;; استخراج الضلع الأقرب يساراً ويميناً
                    (setq x_bounds (get_closest_x_bounds cur_y min_x max_x))
                    (setq left_bound (car x_bounds)
                          right_bound (cadr x_bounds))

                    (setq pts_seq (list left_bound))
                    (foreach px row_x_pts
                      (if (> px (+ left_bound 0.05))
                        (setq pts_seq (cons px pts_seq))
                      )
                    )
                    (if (> right_bound (+ (car pts_seq) 0.05))
                      (setq pts_seq (cons right_bound pts_seq))
                    )
                    (setq pts_seq (reverse pts_seq))

                    (setq dim_y_line
                      (if (= *MPA_DimPos* 0)
                        (- (cadr *MPA_PtMin*) off_d (* r_idx (/ off_d 1.5)))
                        (+ cur_y (/ off_d 2.5))
                      )
                    )

                    (setq k 0)
                    (while (< k (1- (length pts_seq)))
                      (safe_add_dim
                        (list (nth k pts_seq) cur_y 0.0)
                        (list (nth (1+ k) pts_seq) cur_y 0.0)
                        (list (nth k pts_seq) dim_y_line 0.0)
                        0.0
                      )
                      (setq k (1+ k))
                    )
                    (setq r_idx (1+ r_idx))
                  )
                )
              )
            )
          )

          ;; أبعاد المحور الرأسي (Y)
          (setq active_i_list '())
          (foreach item valid_items
            (if (not (member (car item) active_i_list))
              (setq active_i_list (cons (car item) active_i_list))
            )
          )
          (setq active_i_list (vl-sort active_i_list '<))

          (setq cols_to_dim (if (= *MPA_DimScope* 0) (list (car active_i_list)) active_i_list))
          (setq c_idx 0)

          (foreach curr_i cols_to_dim
            (if curr_i
              (progn
                (setq cur_x (+ (car *MPA_PtMin*) ex (* curr_i sx)))
                (setq col_y_pts '())
                (foreach item valid_items
                  (if (= (car item) curr_i)
                    (setq col_y_pts (cons (cadr (nth 2 item)) col_y_pts))
                  )
                )
                (setq col_y_pts (vl-sort col_y_pts '<))

                (if col_y_pts
                  (progn
                    (setq min_y (car col_y_pts)
                          max_y (last col_y_pts))
                    ;; استخراج الضلع الأقرب أسفلاً وأعلى
                    (setq y_bounds (get_closest_y_bounds cur_x min_y max_y))
                    (setq bot_bound (car y_bounds)
                          top_bound (cadr y_bounds))

                    (setq pts_y_seq (list bot_bound))
                    (foreach py col_y_pts
                      (if (> py (+ bot_bound 0.05))
                        (setq pts_y_seq (cons py pts_y_seq))
                      )
                    )
                    (if (> top_bound (+ (car pts_y_seq) 0.05))
                      (setq pts_y_seq (cons top_bound pts_y_seq))
                    )
                    (setq pts_y_seq (reverse pts_y_seq))

                    (setq dim_x_line
                      (if (= *MPA_DimPos* 0)
                        (- (car *MPA_PtMin*) off_d (* c_idx (/ off_d 1.5)))
                        (+ cur_x (/ off_d 2.5))
                      )
                    )

                    (setq k 0)
                    (while (< k (1- (length pts_y_seq)))
                      (safe_add_dim
                        (list cur_x (nth k pts_y_seq) 0.0)
                        (list cur_x (nth (1+ k) pts_y_seq) 0.0)
                        (list dim_x_line (nth k pts_y_seq) 0.0)
                        (/ pi 2.0)
                      )
                      (setq k (1+ k))
                    )
                    (setq c_idx (1+ c_idx))
                  )
                )
              )
            )
          )
        )
      )

      ;; 8. إدراج التقرير الهندسي خارج الشكل تماماً بالأعلى
      (if (and (= *MPA_AddTable* 1) (= *MPA_AppMode* 1))
        (progn
          (setq text_h (/ (max W H) 36.0))
          (setq off_table (/ (max W H) 10.0))
          (setq stamp_pt (list (car *MPA_PtMin*) (+ (cadr *MPA_PtMax*) off_table) 0.0))
          (setq defined_w (* (max W 12.0) 1.6))
          
          (setq stamp_txt
            (strcat
              "\\A1;{\\fArial|b1;ELECTRICAL LIGHTING CALCULATION SCHEDULE / تقرير حسابات الإنارة}\n"
              "----------------------------------------------------------------------------------------------------\n"
              "• Space Area (مساحة الفراغ الحقيقية): " (rtos Area 2 2) " m²  |  Bounding Box: [" (rtos W 2 2) "m x " (rtos H 2 2) "m]\n"
              "• Luminaire Block (الكشاف المستخدم): " cur_blk " [" (rtos *MPA_Watts* 2 0) "W / " (rtos *MPA_Lumens* 2 0) " lm]\n"
              "• Effective Fixtures (الكشافات داخل الحدود): " (itoa (length valid_items)) " Fixtures (Excluded Out-of-Bounds: " (itoa (- (* nx ny) (length valid_items))) ")\n"
              "• Target Illuminance (المستهدف): " (rtos *MPA_TargetLux* 2 0) " Lux\n"
              "• Maintained Average Lux (المحسوب فعلياً): " (rtos (nth 0 lux_res) 2 1) " Lux\n"
              "• Lighting Power Density (LPD): " (rtos (nth 1 lux_res) 2 2) " W/m²\n"
              "• Engineering Factors: Room Index (K)=" (rtos (nth 2 lux_res) 2 2) "  |  CU=" (rtos *MPA_CU* 2 2) "  |  MF=" (rtos *MPA_MF* 2 2)
            )
          )
          (setq mtxt (vla-addmtext spc (vlax-3d-point stamp_pt) defined_w stamp_txt))
          (vla-put-attachmentpoint mtxt 7) ; Bottom-Left
          (vla-put-insertionpoint mtxt (vlax-3d-point stamp_pt))
          (vla-put-height mtxt text_h)
        )
      )

      (princ (strcat "\nتم التوزيع بنجاح (" (itoa (length valid_items)) " كشاف) داخل الحدود مع الأبعاد والتقرير."))
    )
    (princ "\nتم إلغاء الأمر.")
  )

  (vla-endundomark doc)
  (princ)
)

;; اختصارات التشغيل
(defun c:X2X () (c:X2X_CORE))
(defun c:x2x () (c:X2X_CORE))
(defun c:ء2ء () (c:X2X_CORE))
