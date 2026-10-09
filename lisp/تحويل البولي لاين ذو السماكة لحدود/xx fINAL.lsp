;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: XX
;;; الملف الأصلي: xx fINAL.lsp
;;; =========================================================================
;;; Command: XX
;;; Convert wide 2D polylines (including tapered/arrow widths) to outlines.
;;;
;;; - Open source polyline  -> one closed outline polyline.
;;; - Closed source polyline -> two closed boundary polylines (when valid).
;;; - Preserves constant-width ARC boundaries as true bulged polyline arcs.
;;; - Tessellates only non-circular, variable-width arc boundaries.
;;; - Preserves layer, color and common display properties.
;;; - Every command run is enclosed in one AutoCAD undo mark.
;;;
;;; User-tunable settings:
;;;   *XX-ARC-MAX-ANGLE*  Maximum arc tessellation angle in degrees.
;;;   *XX-MITER-LIMIT*    Safety limit for nearly parallel/reversing joins.
;;; =========================================================================

(vl-load-com)

(if (not (boundp '*XX-ARC-MAX-ANGLE*))
  (setq *XX-ARC-MAX-ANGLE* 2.0)
)
(if (not (boundp '*XX-MITER-LIMIT*))
  (setq *XX-MITER-LIMIT* 1000000.0)
)

(setq *XX-EPS* 1.0e-9)

;;; -------------------------------------------------------------------------
;;; Small geometry utilities (all outline calculations are in source OCS XY).
;;; -------------------------------------------------------------------------

(defun xx:v+ (a b)
  (list (+ (car a) (car b)) (+ (cadr a) (cadr b)))
)

(defun xx:v- (a b)
  (list (- (car a) (car b)) (- (cadr a) (cadr b)))
)

(defun xx:v* (v s)
  (list (* (car v) s) (* (cadr v) s))
)

(defun xx:cross (a b)
  (- (* (car a) (cadr b)) (* (cadr a) (car b)))
)

(defun xx:dot (a b)
  (+ (* (car a) (car b)) (* (cadr a) (cadr b)))
)

(defun xx:len (v)
  (sqrt (xx:dot v v))
)

(defun xx:dist (a b)
  (xx:len (xx:v- a b))
)

(defun xx:unit (v / n)
  (setq n (xx:len v))
  (if (> n *XX-EPS*) (xx:v* v (/ 1.0 n)))
)

(defun xx:left-normal (v / u)
  (if (setq u (xx:unit v))
    (list (- (cadr u)) (car u))
  )
)

(defun xx:lerp (a b t0)
  (xx:v+ a (xx:v* (xx:v- b a) t0))
)

(defun xx:lerp-real (a b t0)
  (+ a (* (- b a) t0))
)

(defun xx:2d (p)
  (list (float (car p)) (float (cadr p)))
)

(defun xx:bit-set-p (value mask)
  (/= 0 (logand value mask))
)

(defun xx:line-intersection (p r q s / den den-tol t0)
  (setq den (xx:cross r s)
        den-tol (* *XX-EPS* (xx:len r) (xx:len s)))
  (if (> (abs den) den-tol)
    (progn
      (setq t0 (/ (xx:cross (xx:v- q p) s) den))
      (xx:v+ p (xx:v* r t0))
    )
  )
)

(defun xx:midpoint (a b)
  (xx:v* (xx:v+ a b) 0.5)
)

(defun xx:remove-last (lst)
  (reverse (cdr (reverse lst)))
)

(defun xx:clean-open-points (pts / out p)
  (foreach p pts
    (if (or (null out) (> (xx:dist p (car out)) *XX-EPS*))
      (setq out (cons p out))
    )
  )
  (reverse out)
)

(defun xx:clean-closed-points (pts / clean)
  (setq clean (xx:clean-open-points pts))
  (if (and (> (length clean) 1)
           (<= (xx:dist (car clean) (last clean)) *XX-EPS*))
    (setq clean (xx:remove-last clean))
  )
  clean
)

(defun xx:signed-area (pts / area i n p q)
  (setq area 0.0
        i 0
        n (length pts))
  (if (> n 2)
    (repeat n
      (setq p (nth i pts)
            q (nth (rem (1+ i) n) pts)
            area (+ area (xx:cross p q))
            i (1+ i))
    )
  )
  (* 0.5 area)
)

(defun xx:valid-loop-p (pts / scale p minx maxx miny maxy)
  ;; Use the loop's span rather than absolute coordinates.  This remains
  ;; reliable in survey/civil drawings located far from the WCS origin.
  (if pts
    (progn
      (setq minx (caar pts)
            maxx minx
            miny (cadar pts)
            maxy miny)
      (foreach p (cdr pts)
        (setq minx (min minx (car p))
              maxx (max maxx (car p))
              miny (min miny (cadr p))
              maxy (max maxy (cadr p))))
      (setq scale (max 1.0 (- maxx minx) (- maxy miny)))
    )
  )
  (and (>= (length pts) 3)
       (> (abs (xx:signed-area pts)) (* *XX-EPS* scale scale)))
)

;;; -------------------------------------------------------------------------
;;; Entity parsing.
;;; A vertex record is: (point start-width end-width bulge).
;;; -------------------------------------------------------------------------

(defun xx:entity-properties (data / result code item)
  ;; Preserve common graphical properties.  Missing properties remain ByLayer.
  (foreach code '(67 410 8 6 62 420 430 48 370 440 390 347)
    (if (setq item (assoc code data))
      (setq result (append result (list item)))
    )
  )
  result
)

(defun xx:finish-lw-vertex (p sw ew bulge)
  (list p (max 0.0 sw) (max 0.0 ew) bulge)
)

(defun xx:parse-lwpolyline (ent data / verts p sw ew bulge item cw normal)
  (setq verts nil
        p nil
        sw 0.0
        ew 0.0
        bulge 0.0
        cw (cdr (assoc 43 data)))
  (foreach item data
    (cond
      ((= (car item) 10)
       (if p
         (setq verts
           (cons (xx:finish-lw-vertex p sw ew bulge) verts))
       )
       (setq p (xx:2d (cdr item))
             sw 0.0
             ew 0.0
             bulge 0.0))
      ((and p (= (car item) 40)) (setq sw (float (cdr item))))
      ((and p (= (car item) 41)) (setq ew (float (cdr item))))
      ((and p (= (car item) 42)) (setq bulge (float (cdr item))))
    )
  )
  (if p
    (setq verts (cons (xx:finish-lw-vertex p sw ew bulge) verts))
  )
  (setq verts (reverse verts))
  ;; DXF 43 is a constant width and overrides individual widths when nonzero.
  (if (and cw (> (abs cw) *XX-EPS*))
    (setq verts
      (mapcar
        '(lambda (v) (list (car v) (abs cw) (abs cw) (cadddr v)))
        verts))
  )
  (setq normal (cdr (assoc 210 data)))
  (if (null normal) (setq normal '(0.0 0.0 1.0)))
  (list
    (cons 'vertices verts)
    (cons 'closed
      (xx:bit-set-p (if (assoc 70 data) (cdr (assoc 70 data)) 0) 1))
    (cons 'elevation (if (assoc 38 data) (cdr (assoc 38 data)) 0.0))
    (cons 'normal normal)
    (cons 'properties (xx:entity-properties data)))
)

(defun xx:parse-old-polyline
  (ent data / flags next vdata verts p sw ew bulge defsw defew normal elev)
  (setq flags (if (assoc 70 data) (cdr (assoc 70 data)) 0))
  (if (/= 0 (logand flags (+ 2 4 8 16 64)))
    (list (cons 'error
      "fitted, 3D, mesh and polyface POLYLINE objects are not supported"))
    (progn
      (setq defsw (if (assoc 40 data) (cdr (assoc 40 data)) 0.0)
            defew (if (assoc 41 data) (cdr (assoc 41 data)) 0.0)
            verts nil
            next (entnext ent))
      (while next
        (setq vdata (entget next))
        (cond
          ((= (cdr (assoc 0 vdata)) "VERTEX")
           (setq p (xx:2d (cdr (assoc 10 vdata)))
                 sw (if (assoc 40 vdata) (cdr (assoc 40 vdata)) defsw)
                 ew (if (assoc 41 vdata) (cdr (assoc 41 vdata)) defew)
                 bulge (if (assoc 42 vdata) (cdr (assoc 42 vdata)) 0.0)
                 verts
                   (cons
                     (xx:finish-lw-vertex
                       p (float sw) (float ew) (float bulge))
                     verts)))
          ((= (cdr (assoc 0 vdata)) "SEQEND")
           (setq next nil))
        )
        (if next (setq next (entnext next)))
      )
      (setq normal (cdr (assoc 210 data)))
      (if (null normal) (setq normal '(0.0 0.0 1.0)))
      (setq elev
        (if (and (assoc 10 data) (caddr (cdr (assoc 10 data))))
          (caddr (cdr (assoc 10 data)))
          0.0))
      (list
        (cons 'vertices (reverse verts))
        (cons 'closed (xx:bit-set-p flags 1))
        (cons 'elevation elev)
        (cons 'normal normal)
        (cons 'properties (xx:entity-properties data)))
    )
  )
)

(defun xx:parse-polyline (ent / data typ)
  (setq data (entget ent)
        typ (cdr (assoc 0 data)))
  (cond
    ((= typ "LWPOLYLINE") (xx:parse-lwpolyline ent data))
    ((= typ "POLYLINE") (xx:parse-old-polyline ent data))
    (T (list (cons 'error "object is not a supported polyline")))
  )
)

;;; -------------------------------------------------------------------------
;;; Centerline tessellation.
;;; Each returned segment is: (start-point end-point start-width end-width).
;;; -------------------------------------------------------------------------

(defun xx:arc-center (p0 p1 bulge / chord c mid off n)
  (setq chord (xx:v- p1 p0)
        c (xx:len chord))
  (if (and (> c *XX-EPS*) (> (abs bulge) *XX-EPS*))
    (progn
      (setq mid (xx:midpoint p0 p1)
            n (xx:left-normal chord)
            off (/ (* c (- 1.0 (* bulge bulge))) (* 4.0 bulge)))
      (xx:v+ mid (xx:v* n off))
    )
  )
)

(defun xx:tessellate-one
  (p0 p1 sw ew bulge arc-id
    / result center theta step count i t0 t1 a0 radius q0 q1 w0 w1
      radial0 radial1 direction-sign l0 l1 r0 r1 exact-arc piece-theta)
  (if (<= (xx:dist p0 p1) *XX-EPS*)
    nil
    (if (<= (abs bulge) *XX-EPS*)
      (list (list p0 p1 sw ew))
      (progn
        (setq center (xx:arc-center p0 p1 bulge)
              theta (* 4.0 (atan bulge))
              step (* pi (/ (max 0.1 *XX-ARC-MAX-ANGLE*) 180.0))
              count (max 1 (fix (+ 0.999999999 (/ (abs theta) step))))
              a0 (atan (- (cadr p0) (cadr center))
                       (- (car p0) (car center)))
              radius (xx:dist p0 center)
              direction-sign (if (< theta 0.0) -1.0 1.0)
              exact-arc
                (<= (abs (- sw ew))
                    (* *XX-EPS* (max 1.0 (abs sw) (abs ew))))
              i 0
              result nil)
        (repeat count
          (setq t0 (/ (float i) count)
                t1 (/ (float (1+ i)) count)
                q0 (if (= i 0)
                     p0
                     (list
                       (+ (car center) (* radius (cos (+ a0 (* theta t0)))))
                       (+ (cadr center) (* radius (sin (+ a0 (* theta t0)))))))
                q1 (if (= (1+ i) count)
                     p1
                     (list
                       (+ (car center) (* radius (cos (+ a0 (* theta t1)))))
                       (+ (cadr center) (* radius (sin (+ a0 (* theta t1)))))))
                w0 (xx:lerp-real sw ew t0)
                w1 (xx:lerp-real sw ew t1)
                radial0 (xx:unit (xx:v- q0 center))
                radial1 (xx:unit (xx:v- q1 center))
                l0
                  (xx:v+ q0
                    (xx:v* radial0 (* -0.5 direction-sign w0)))
                l1
                  (xx:v+ q1
                    (xx:v* radial1 (* -0.5 direction-sign w1)))
                r0
                  (xx:v+ q0
                    (xx:v* radial0 (* 0.5 direction-sign w0)))
                r1
                  (xx:v+ q1
                    (xx:v* radial1 (* 0.5 direction-sign w1)))
                piece-theta (* theta (- t1 t0))
                result
                  (cons
                    (list q0 q1 w0 w1 l0 l1 r0 r1
                      (if exact-arc arc-id nil)
                      (if exact-arc piece-theta 0.0))
                    result)
                i (1+ i))
        )
        (reverse result)
      )
    )
  )
)

(defun xx:build-segments (vertices closed / count limit i a b piece result)
  (setq count (length vertices)
        limit (if closed count (1- count))
        i 0
        result nil)
  (repeat (max 0 limit)
    (setq a (nth i vertices)
          b (nth (rem (1+ i) count) vertices)
          piece
            (xx:tessellate-one
              (car a) (car b) (cadr a) (caddr a) (cadddr a) i))
    (setq result (append result piece)
          i (1+ i))
  )
  result
)

;;; -------------------------------------------------------------------------
;;; Stroke construction and miter joins.
;;; -------------------------------------------------------------------------

(defun xx:segment-side-point (seg side at-end / p d n width)
  (if (>= (length seg) 8)
    (cond
      ((and (> side 0.0) at-end) (nth 5 seg))
      ((> side 0.0) (nth 4 seg))
      (at-end (nth 7 seg))
      (T (nth 6 seg)))
    (progn
      (setq p (if at-end (cadr seg) (car seg))
            width (if at-end (cadddr seg) (caddr seg))
            d (xx:v- (cadr seg) (car seg))
            n (xx:left-normal d))
      (xx:v+ p (xx:v* n (* side 0.5 width)))
    )
  )
)

(defun xx:join-side
  (previous following side
    / a0 a1 b0 b1 ra rb center-a center-b wa wb tol turn ip scale)
  (setq a0 (xx:segment-side-point previous side nil)
        a1 (xx:segment-side-point previous side T)
        b0 (xx:segment-side-point following side nil)
        b1 (xx:segment-side-point following side T)
        center-a (xx:v- (cadr previous) (car previous))
        center-b (xx:v- (cadr following) (car following))
        wa (cadddr previous)
        wb (caddr following)
        tol (* *XX-EPS* (max 1.0 (abs wa) (abs wb)))
        turn
          (/ (abs (xx:cross center-a center-b))
             (* (xx:len center-a) (xx:len center-b))))
  (if (and (> (abs (- wa wb)) tol)
           (<= turn *XX-EPS*))
    ;; A width jump on a straight run is a real shoulder/arrow barb.
    (list a1 b0)
    (progn
      ;; At an actual corner, intersect both boundary lines even when their
      ;; widths differ.  This prevents crossed diagonals and gives the square
      ;; inside/outside corners expected from a mitered wide polyline.
      (setq ra (xx:v- a1 a0)
            rb (xx:v- b1 b0)
            ip (xx:line-intersection a0 ra b0 rb)
            scale (max 1.0 (xx:len ra) (xx:len rb) (abs wa) (abs wb)))
      (cond
        ((and ip
              (< (xx:dist ip (xx:midpoint a1 b0))
                 (* *XX-MITER-LIMIT* scale)))
         (list ip))
        ((<= (xx:dist a1 b0) tol)
         (list (xx:midpoint a1 b0)))
        (T
         ;; Degenerate 180-degree reversal or corrupt near-parallel geometry.
         (list a1 b0))
      )
    )
  )
)

(defun xx:open-side (segments side / result i count)
  (setq count (length segments)
        result (list (xx:segment-side-point (car segments) side nil))
        i 1)
  (while (< i count)
    (setq result
      (append result
        (xx:join-side (nth (1- i) segments) (nth i segments) side))
          i (1+ i))
  )
  (setq result
    (append result
      (list (xx:segment-side-point (last segments) side T))))
  (xx:clean-open-points result)
)

(defun xx:closed-side (segments side / result i count previous current)
  (setq count (length segments)
        result nil
        i 0)
  (repeat count
    (setq previous (nth (rem (+ i count -1) count) segments)
          current (nth i segments)
          result (append result (xx:join-side previous current side))
          i (1+ i))
  )
  (xx:clean-closed-points result)
)

(defun xx:make-outlines (segments closed / left right right-forward outline loops)
  (if closed
    (progn
      (setq left (xx:closed-side segments 1.0)
            right-forward (xx:closed-side segments -1.0)
            ;; Reverse orientation without moving the cyclic start point.
            ;; Keeping the start at a source join lets closing arc runs merge
            ;; back into one true bulge segment.
            right
              (if right-forward
                (cons (car right-forward) (reverse (cdr right-forward))))
            loops nil)
      (if (xx:valid-loop-p left) (setq loops (append loops (list left))))
      (if (xx:valid-loop-p right) (setq loops (append loops (list right))))
      loops
    )
    (progn
      (setq left (xx:open-side segments 1.0)
            right (xx:open-side segments -1.0)
            outline (xx:clean-closed-points (append left (reverse right))))
      (if (xx:valid-loop-p outline) (list outline))
    )
  )
)

;;; Match exact constant-width arc edges and combine their tessellated points
;;; back into true LWPOLYLINE bulge segments.  The temporary tessellation is
;;; retained internally only to keep the general corner/join engine robust.

(defun xx:same-point-p (a b)
  (equal a b (* 100.0 *XX-EPS*))
)

(defun xx:arc-edge-info (p q segments / info seg arc-id theta)
  (foreach seg segments
    (if (and (null info) (>= (length seg) 10) (nth 8 seg))
      (progn
        (setq arc-id (nth 8 seg)
              theta (nth 9 seg))
        (cond
          ((and (xx:same-point-p p (nth 4 seg))
                (xx:same-point-p q (nth 5 seg)))
           (setq info (list arc-id theta)))
          ((and (xx:same-point-p p (nth 5 seg))
                (xx:same-point-p q (nth 4 seg)))
           (setq info (list arc-id (- theta))))
          ((and (xx:same-point-p p (nth 6 seg))
                (xx:same-point-p q (nth 7 seg)))
           (setq info (list arc-id theta)))
          ((and (xx:same-point-p p (nth 7 seg))
                (xx:same-point-p q (nth 6 seg)))
           (setq info (list arc-id (- theta))))
        )
      )
    )
  )
  info
)

(defun xx:bulge-from-angle (angle / quarter c)
  (setq quarter (* 0.25 angle)
        c (cos quarter))
  (if (> (abs c) *XX-EPS*)
    (/ (sin quarter) c)
    0.0)
)

(defun xx:compress-loop-arcs
  (pts segments / result n i p q info arc-id total-angle j next-info bulge)
  (setq result nil
        n (length pts)
        i 0)
  (while (< i n)
    (setq p (nth i pts))
    (if (= i (1- n))
      ;; The closing edge is kept separately; this also avoids an invalid
      ;; one-vertex result for a theoretical full-circle run.
      (progn
        (setq info (xx:arc-edge-info p (car pts) segments)
              bulge (if info (xx:bulge-from-angle (cadr info)) 0.0)
              result (cons (list p bulge) result)
              i (1+ i)))
      (progn
        (setq q (nth (1+ i) pts)
              info (xx:arc-edge-info p q segments))
        (if info
          (progn
            (setq arc-id (car info)
                  total-angle (cadr info)
                  j (1+ i))
            (while (and (< j (1- n))
                        (setq next-info
                          (xx:arc-edge-info
                            (nth j pts) (nth (1+ j) pts) segments))
                        (= (car next-info) arc-id))
              (setq total-angle (+ total-angle (cadr next-info))
                    j (1+ j))
            )
            ;; If this arc finishes on the loop's closing edge, merge that
            ;; final piece too.  A prior vertex must exist so the result can
            ;; never collapse into an invalid one-vertex full circle.
            (if (and (= j (1- n))
                     (> i 0)
                     (setq next-info
                       (xx:arc-edge-info (nth j pts) (car pts) segments))
                     (= (car next-info) arc-id))
              (setq total-angle (+ total-angle (cadr next-info))
                    j n)
            )
            (setq result
              (cons (list p (xx:bulge-from-angle total-angle)) result)
                  i j)
          )
          (setq result (cons (list p 0.0) result)
                i (1+ i))
        )
      )
    )
  )
  (reverse result)
)

;;; -------------------------------------------------------------------------
;;; Output and per-entity transaction.
;;; -------------------------------------------------------------------------

(defun xx:make-lwpolyline (vertices elevation normal properties / dxf vertex)
  (setq dxf
    (append
      (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity"))
      properties
      (list
        '(100 . "AcDbPolyline")
        (cons 90 (length vertices))
        '(70 . 1)
        (cons 38 elevation))))
  (foreach vertex vertices
    (setq dxf (append dxf (list (cons 10 (car vertex)))))
    (if (> (abs (cadr vertex)) *XX-EPS*)
      (setq dxf (append dxf (list (cons 42 (cadr vertex)))))
    )
  )
  (setq dxf (append dxf (list (cons 210 normal))))
  (entmakex dxf)
)

(defun xx:layer-locked-p (ent / data layer layerdata)
  (setq data (entget ent)
        layer (cdr (assoc 8 data))
        layerdata (tblsearch "LAYER" layer))
  (and layerdata
       (xx:bit-set-p
         (if (assoc 70 layerdata) (cdr (assoc 70 layerdata)) 0)
         4))
)

(defun xx:has-positive-width-p (vertices / found v)
  (setq found nil)
  (foreach v vertices
    (if (or (> (cadr v) *XX-EPS*) (> (caddr v) *XX-EPS*))
      (setq found T)
    )
  )
  found
)

(defun xx:erase-created (created / e)
  (foreach e created
    (if (entget e) (entdel e))
  )
)

(defun xx:process-one
  (ent / parsed error vertices closed segments loops created loop output-vertices newent)
  (cond
    ((xx:layer-locked-p ent)
     (list nil "source layer is locked"))
    (T
     (setq parsed (xx:parse-polyline ent)
           error (cdr (assoc 'error parsed)))
     (cond
       (error (list nil error))
       ((< (length (cdr (assoc 'vertices parsed))) 2)
        (list nil "polyline has fewer than two vertices"))
       ((not (xx:has-positive-width-p (cdr (assoc 'vertices parsed))))
        (list nil "polyline has zero width"))
       (T
        (setq vertices (cdr (assoc 'vertices parsed))
              closed (cdr (assoc 'closed parsed))
              segments (xx:build-segments vertices closed))
        (if (< (length segments) (if closed 2 1))
          (list nil "polyline has insufficient non-zero-length segments")
          (progn
            (setq loops (xx:make-outlines segments closed)
                  created nil)
            (if (null loops)
              (list nil "outline is geometrically degenerate")
              (progn
                (foreach loop loops
                  (setq output-vertices (xx:compress-loop-arcs loop segments))
                  (if (setq newent
                        (xx:make-lwpolyline
                          output-vertices
                          (cdr (assoc 'elevation parsed))
                          (cdr (assoc 'normal parsed))
                          (cdr (assoc 'properties parsed))))
                    (setq created (cons newent created))
                  )
                )
                (cond
                  ((/= (length created) (length loops))
                   (xx:erase-created created)
                   (list nil "AutoCAD could not create every outline entity"))
                  ((null (entdel ent))
                   (xx:erase-created created)
                   (list nil "source polyline could not be erased"))
                  (T (list T (length created)))
                )
              )
            )
          )
        )
       )
     )
    )
  )
)

;;; -------------------------------------------------------------------------
;;; Public command.
;;; -------------------------------------------------------------------------

(defun c:XX (/ *error* acad doc undo-open ss index ent result converted skipped outlines message)
  (setq acad (vlax-get-acad-object)
        doc (vla-get-ActiveDocument acad)
        undo-open nil)

  (defun *error* (msg)
    (if undo-open
      (progn
        (vl-catch-all-apply 'vla-EndUndoMark (list doc))
        (setq undo-open nil))
    )
    (if (and msg
             (/= msg "Function cancelled")
             (/= msg "quit / exit abort"))
      (princ (strcat "\nXX error: " msg))
    )
    (princ)
  )

  (princ "\nXX converts wide 2D polylines to closed outline polylines.")
  (princ "\nSelect wide 2D polylines: ")
  (if (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
    (progn
      (if (not
            (vl-catch-all-error-p
              (vl-catch-all-apply 'vla-StartUndoMark (list doc))))
        (setq undo-open T)
      )
      (setq index 0
            converted 0
            skipped 0
            outlines 0)
      (repeat (sslength ss)
        (setq ent (ssname ss index)
              result (vl-catch-all-apply 'xx:process-one (list ent)))
        (cond
          ((vl-catch-all-error-p result)
           (setq skipped (1+ skipped)
                 message (vl-catch-all-error-message result))
           (princ
             (strcat "\nXX skipped item " (itoa (1+ index)) ": " message)))
          ((car result)
           (setq converted (1+ converted)
                 outlines (+ outlines (cadr result))))
          (T
           (setq skipped (1+ skipped))
           (princ
             (strcat "\nXX skipped item " (itoa (1+ index)) ": " (cadr result))))
        )
        (setq index (1+ index))
      )
      (if undo-open
        (progn
          (vl-catch-all-apply 'vla-EndUndoMark (list doc))
          (setq undo-open nil))
      )
      (princ
        (strcat
          "\nXX complete: " (itoa converted) " source polyline(s) converted, "
          (itoa outlines) " outline(s) created, "
          (itoa skipped) " skipped."))
    )
    (princ "\nXX: nothing selected.")
  )
  (princ)
)

(princ "\nXX loaded. Type XX to convert wide 2D polylines to outlines.")
(princ)
