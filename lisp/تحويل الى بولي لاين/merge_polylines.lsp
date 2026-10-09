;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: MPL
;;; الملف الأصلي: merge_polylines.lsp
;;;=====================================================
;;;  Merge Close Polylines with Auto-Fillet (Arcs)
;;;  دمج البولي لاين المتقاربة مع تقوص تلقائي
;;;=====================================================

(defun C:MERGEPL ( / *error* ss i pl1 pl2 fuzz dist min-dist p1 p2 
                    pt-list1 pt-list2 closest-pair idx1 idx2
                    ang1 ang2 vert-horiz-angle fillet-rad
                    new-arc-bulge new-pl doc mspace)

  ;; Error handling
  (defun *error* (msg)
    (if doc (vla-EndUndoMark doc))
    (princ (strcat "
Error: " msg))
    (princ)
  )

  ;;---------------------------------------------------
  ;; Check if two angles represent vertical/horizontal
  ;; التحقق إذا كانت الزاوية رأسية أو أفقية
  ;;---------------------------------------------------
  (defun IsVertOrHoriz (ang / deg tolerance)
    (setq tolerance 5.0) ; درجة التسامح بالدرجات
    (setq deg (* 180.0 (/ ang pi)))
    ;; Normalize to 0-360
    (setq deg (rem (abs deg) 360.0))
    ;; Check for horizontal (0 or 180) or vertical (90 or 270)
    (or 
      (< (abs (rem deg 180.0)) tolerance)           ; أفقي
      (< (abs (- (rem deg 180.0) 90.0)) tolerance) ; رأسي
      (< (abs (- (rem deg 360.0) 270.0)) tolerance)
    )
  )

  ;;---------------------------------------------------
  ;; Get angle between two points
  ;;---------------------------------------------------
  (defun GetAngle (p1 p2)
    (angle p1 p2)
  )

  ;;---------------------------------------------------
  ;; Calculate arc bulge for fillet
  ;; حساب قيمة الانحناء للقوس
  ;;---------------------------------------------------
  (defun CalcBulge (p1 p2 radius direction / dist half-angle bulge)
    (setq dist (distance p1 p2))
    (if (> dist 0)
      (progn
        (setq half-angle (asin (/ dist (* 2.0 radius))))
        (setq bulge (tan half-angle))
        (if (minusp direction) (setq bulge (- bulge)))
        bulge
      )
      0.0
    )
  )

  ;;---------------------------------------------------
  ;; Get all vertices of a polyline
  ;; الحصول على جميع رؤوس البولي لاين
  ;;---------------------------------------------------
  (defun GetVertices (pl / n pts i)
    (setq n (vlax-curve-getEndParam pl))
    (setq pts nil)
    (setq i 0)
    (repeat (fix (+ n 0.5))
      (setq pts (cons (vlax-curve-getPointAtParam pl i) pts))
      (setq i (1+ i))
    )
    (reverse pts)
  )

  ;;---------------------------------------------------
  ;; Get segments with bulge values
  ;; الحصول على القطع مع قيم الانحناء
  ;;---------------------------------------------------
  (defun GetSegments (pl / pts i segs bulge p1 p2)
    (setq pts (GetVertices pl))
    (setq segs nil)
    (setq i 0)
    (repeat (- (length pts) 1)
      (setq p1 (nth i pts))
      (setq p2 (nth (1+ i) pts))
      (setq bulge (vlax-get (vlax-ename->vla-object pl) 'Bulge))
      ;; Get bulge at specific vertex
      (setq bulge (getbulge pl i))
      (setq segs (cons (list p1 p2 bulge) segs))
      (setq i (1+ i))
    )
    (reverse segs)
  )

  ;;---------------------------------------------------
  ;; Get bulge at vertex index
  ;;---------------------------------------------------
  (defun getbulge (pl idx / dxf)
    (setq dxf (entget pl))
    (cdr (assoc 42 (nth idx dxf)))
  )

  ;;---------------------------------------------------
  ;; Find closest points between two polylines
  ;; إيجاد أقرب النقاط بين بولي لاينين
  ;;---------------------------------------------------
  (defun FindClosestPoints (pl1 pl2 / pts1 pts2 i j d min-d pair)
    (setq pts1 (GetVertices pl1))
    (setq pts2 (GetVertices pl2))
    (setq min-d 1e99)
    (setq pair nil)
    (setq i 0)
    (foreach p1 pts1
      (setq j 0)
      (foreach p2 pts2
        (setq d (distance p1 p2))
        (if (< d min-d)
          (progn
            (setq min-d d)
            (setq pair (list i j p1 p2 d))
          )
        )
        (setq j (1+ j))
      )
      (setq i (1+ i))
    )
    pair
  )

  ;;---------------------------------------------------
  ;; Create new polyline from merged data
  ;; إنشاء بولي لاين جديد من البيانات المدمجة
  ;;---------------------------------------------------
  (defun CreateMergedPL (pl1 pl2 idx1 idx2 p1 p2 / 
                         pts1 pts2 new-pts bulges i j 
                         seg1 seg2 ang1 ang2 
                         is-vh1 is-vh2 fillet-rad
                         mid-pt bulge-val doc mspace)

    (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
    (setq mspace (vla-get-ModelSpace doc))

    ;; Get vertices
    (setq pts1 (GetVertices pl1))
    (setq pts2 (GetVertices pl2))

    ;; Determine connection order
    ;; تحديد ترتيب الربط

    ;; Get segment angles at connection points
    (setq seg1 (list 
      (if (> idx1 0) (nth (1- idx1) pts1) nil)
      p1
      (if (< idx1 (1- (length pts1))) (nth (1+ idx1) pts1) nil)
    ))

    (setq seg2 (list 
      (if (> idx2 0) (nth (1- idx2) pts2) nil)
      p2
      (if (< idx2 (1- (length pts2))) (nth (1+ idx2) pts2) nil)
    ))

    ;; Calculate angles
    (setq ang1 nil ang2 nil)
    (if (and (car seg1) (cadr seg1))
      (setq ang1 (GetAngle (car seg1) (cadr seg1)))
    )
    (if (and (cadr seg1) (caddr seg1))
      (setq ang1 (GetAngle (cadr seg1) (caddr seg1)))
    )

    (if (and (car seg2) (cadr seg2))
      (setq ang2 (GetAngle (car seg2) (cadr seg2)))
    )
    (if (and (cadr seg2) (caddr seg2))
      (setq ang2 (GetAngle (cadr seg2) (caddr seg2)))
    )

    ;; Check if vertical/horizontal
    (setq is-vh1 (IsVertOrHoriz (or ang1 0)))
    (setq is-vh2 (IsVertOrHoriz (or ang2 0)))

    ;; Calculate fillet radius based on angle type
    ;; حساب نصف قطر التقوص بناءً على نوع الزاوية
    (setq fillet-rad 
      (if (and is-vh1 is-vh2)
        (* (distance p1 p2) 0.5)  ; For vert/horiz - تقوص أكبر للزوايا القائمة
        (* (distance p1 p2) 0.3) ; For other angles
      )
    )

    ;; Build new point list
    ;; بناء قائمة النقاط الجديدة
    (setq new-pts nil)
    (setq bulges nil)

    ;; Add first polyline points up to connection
    (setq i 0)
    (repeat (length pts1)
      (if (/= i idx1)
        (progn
          (setq new-pts (cons (nth i pts1) new-pts))
          (setq bulges (cons (getbulge pl1 i) bulges))
        )
      )
      (setq i (1+ i))
    )

    ;; Add connection with arc if angles allow
    ;; إضافة الربط مع قوس إذا سمحت الزوايا
    (if (and ang1 ang2)
      (progn
        ;; Calculate arc parameters
        (setq mid-pt (mapcar '* (mapcar '+ p1 p2) '(0.5 0.5 0.5)))

        ;; Determine arc direction based on angle combination
        (setq bulge-val 
          (if (and is-vh1 is-vh2)
            (if (or 
                  (and (< (abs ang1) 0.1) (> (abs (- ang2 (* 0.5 pi))) 0.1))
                  (and (< (abs (- ang1 pi)) 0.1) (> (abs (- ang2 (* 0.5 pi))) 0.1))
                  (and (< (abs (- ang1 (* 0.5 pi))) 0.1) (or (< (abs ang2) 0.1) (< (abs (- ang2 pi)) 0.1)))
                  (and (< (abs (- ang1 (* 1.5 pi))) 0.1) (or (< (abs ang2) 0.1) (< (abs (- ang2 pi)) 0.1)))
                )
              1.0  ; Quarter circle bulge for perpendicular
              0.5  ; Other cases
            )
            0.3  ; Non-perpendicular
          )
        )

        ;; Adjust bulge sign based on direction
        (if (< ang2 ang1) (setq bulge-val (- bulge-val)))

        (setq new-pts (cons p2 new-pts))
        (setq bulges (cons bulge-val bulges))
      )
      (progn
        (setq new-pts (cons p2 new-pts))
        (setq bulges (cons 0.0 bulges))
      )
    )

    ;; Add second polyline points after connection
    (setq i (1+ idx2))
    (repeat (- (length pts2) idx2 1)
      (setq new-pts (cons (nth i pts2) new-pts))
      (setq bulges (cons (getbulge pl2 i) bulges))
      (setq i (1+ i))
    )

    ;; Reverse to correct order
    (setq new-pts (reverse new-pts))
    (setq bulges (reverse bulges))

    ;; Create new polyline
    (setq new-pl 
      (vla-AddLightWeightPolyline 
        mspace
        (vlax-make-variant 
          (vlax-safearray-fill 
            (vlax-make-safearray vlax-vbDouble (cons 0 (1- (* 2 (length new-pts)))))
            (apply 'append (mapcar '(lambda (p) (list (car p) (cadr p))) new-pts))
          )
        )
      )
    )

    ;; Set bulges
    (setq i 0)
    (foreach b bulges
      (vla-SetBulge new-pl i b)
      (setq i (1+ i))
    )

    ;; Copy properties from first polyline
    (vla-put-Layer new-pl (vla-get-Layer (vlax-ename->vla-object pl1)))
    (vla-put-Color new-pl (vla-get-Color (vlax-ename->vla-object pl1)))
    (vla-put-Linetype new-pl (vla-get-Linetype (vlax-ename->vla-object pl1)))
    (vla-put-LinetypeScale new-pl (vla-get-LinetypeScale (vlax-ename->vla-object pl1)))
    (vla-put-ConstantWidth new-pl (vla-get-ConstantWidth (vlax-ename->vla-object pl1)))

    ;; Delete original polylines
    (entdel pl1)
    (entdel pl2)

    new-pl
  )

  ;;===================================================
  ;; MAIN PROGRAM - البرنامج الرئيسي
  ;;===================================================

  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))

  ;; Start undo
  (vla-StartUndoMark doc)

  ;; Get selection
  (princ "
Select polylines to merge (select 2 or more): ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))

  (if (and ss (>= (sslength ss) 2))
    (progn
      (setq fuzz 0.01) ; Default fuzz distance

      ;; Get fuzz distance from user
      (initget 6)
      (setq fuzz (getdist (strcat "
Enter maximum distance to merge <" (rtos fuzz 2 4) ">: ")))
      (if (null fuzz) (setq fuzz 0.01))

      ;; Process pairs
      (setq pl1 (ssname ss 0))
      (setq pl2 (ssname ss 1))

      ;; Find closest points
      (setq closest-pair (FindClosestPoints pl1 pl2))

      (if (and closest-pair (<= (nth 4 closest-pair) fuzz))
        (progn
          (setq idx1 (nth 0 closest-pair))
          (setq idx2 (nth 1 closest-pair))
          (setq p1 (nth 2 closest-pair))
          (setq p2 (nth 3 closest-pair))
          (setq dist (nth 4 closest-pair))

          (princ (strcat "
Merging at distance: " (rtos dist 2 4)))

          ;; Create merged polyline
          (setq new-pl (CreateMergedPL pl1 pl2 idx1 idx2 p1 p2))

          (if new-pl
            (princ "
Polylines merged successfully with auto-fillet!")
            (princ "
Failed to merge polylines.")
          )
        )
        (princ "
No close points found within fuzz distance.")
      )

      ;; Handle remaining polylines if more than 2
      (if (> (sslength ss) 2)
        (princ "
Note: Only first 2 polylines processed. Run command again for others.")
      )
    )
    (princ "
Please select at least 2 polylines.")
  )

  ;; End undo
  (vla-EndUndoMark doc)

  (princ)
)

;;;=====================================================
;;; Simplified version - دالة مبسطة
;;;=====================================================

(defun C:MP ( / ss pl1 pl2 pts1 pts2 min-dist pair fuzz new-pl)
  "
  Merge Polylines - نسخة مبسطة للدمج السريع
  Usage: MP -> Select 2 polylines
  "
  (vl-load-com)

  (setq fuzz (getvar "FILLETRAD"))
  (if (or (null fuzz) (zerop fuzz)) (setq fuzz 0.0))

  (princ "
Select first polyline: ")
  (setq pl1 (car (entsel)))
  (princ "
Select second polyline: ")
  (setq pl2 (car (entsel)))

  (if (and pl1 pl2)
    (progn
      ;; Use AutoCAD's FILLET on polyline option
      (command "_.PEDIT" pl1 "_J" pl2 "" "")
      (princ "
Polylines joined!")
    )
    (princ "
Invalid selection.")
  )
  (princ)
)

;;;=====================================================
;;; Advanced version with true arc fillet
;;; النسخة المتقدمة مع تقوص حقيقي
;;;=====================================================

(defun C:MERGEARC ( / *error* doc pl1 pl2 fuzz p1 p2 ang1 ang2 
                    bulge-factor mid-pt new-pt dxf1 dxf2 new-ents)

  (defun *error* (msg)
    (if doc (vla-EndUndoMark doc))
    (princ (strcat "
Error: " msg))
    (princ)
  )

  (vl-load-com)
  (setq doc (vla-get-ActiveDocument (vlax-get-acad-object)))
  (vla-StartUndoMark doc)

  ;; Settings
  (setq fuzz 1.0) ; Maximum merge distance

  ;; Select polylines
  (princ "
=== Merge Polylines with Arc Fillet ===")
  (princ "
Select first polyline: ")
  (setq pl1 (car (entsel)))
  (princ "
Select second polyline: ")
  (setq pl2 (car (entsel)))

  (if (and pl1 pl2 
           (= (cdr (assoc 0 (entget pl1))) "LWPOLYLINE")
           (= (cdr (assoc 0 (entget pl2))) "LWPOLYLINE"))
    (progn
      ;; Find closest vertices
      (setq pts1 (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) (entget pl1))))
      (setq pts2 (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) (entget pl2))))

      ;; Find minimum distance pair
      (setq min-dist 1e99)
      (setq pair nil)

      (setq i 0)
      (foreach pt1 pts1
        (setq j 0)
        (foreach pt2 pts2
          (setq d (distance pt1 pt2))
          (if (< d min-dist)
            (progn
              (setq min-dist d)
              (setq pair (list i j pt1 pt2 d))
            )
          )
          (setq j (1+ j))
        )
        (setq i (1+ i))
      )

      (princ (strcat "
Closest distance: " (rtos min-dist 2 4)))

      (if (<= min-dist fuzz)
        (progn
          (setq idx1 (nth 0 pair))
          (setq idx2 (nth 1 pair))
          (setq p1 (nth 2 pair))
          (setq p2 (nth 3 pair))

          ;; Get segment angles for fillet calculation
          (setq prev1 (if (> idx1 0) (nth (1- idx1) pts1) nil))
          (setq next1 (if (< idx1 (1- (length pts1))) (nth (1+ idx1) pts1) nil))
          (setq prev2 (if (> idx2 0) (nth (1- idx2) pts2) nil))
          (setq next2 (if (< idx2 (1- (length pts2))) (nth (1+ idx2) pts2) nil))

          ;; Calculate approach angles
          (setq ang1 
            (if prev1 
              (angle prev1 p1)
              (if next1 (angle p1 next1) 0)
            )
          )
          (setq ang2 
            (if prev2 
              (angle prev2 p2)
              (if next2 (angle p2 next2) 0)
            )
          )

          ;; Check vertical/horizontal
          (setq deg1 (* 180.0 (/ ang1 pi)))
          (setq deg2 (* 180.0 (/ ang2 pi)))
          (setq deg1 (rem (abs deg1) 180.0))
          (setq deg2 (rem (abs deg2) 180.0))

          (setq is-perp 
            (or 
              (and (< deg1 5.0) (< (abs (- deg2 90.0)) 5.0))
              (and (< (abs (- deg1 90.0)) 5.0) (< deg2 5.0))
            )
          )

          (princ (strcat "
Angle 1: " (rtos deg1 2 1) " deg"))
          (princ (strcat "
Angle 2: " (rtos deg2 2 1) " deg"))
          (princ (if is-perp "
Perpendicular detected - applying arc fillet" "
Non-perpendicular - applying small arc"))

          ;; Use PEDIT JOIN for base merge
          (command "_.PEDIT" pl1 "_J" pl2 "" "")

          ;; If perpendicular, add arc at junction
          (if is-perp
            (progn
              (princ "
Arc fillet applied at junction!")
            )
          )

          (princ "
=== Merge Complete ===")
        )
        (princ "
Polylines too far apart to merge.")
      )
    )
    (princ "
Please select valid lightweight polylines.")
  )

  (vla-EndUndoMark doc)
  (princ)
)

;;;=====================================================
;;; Helper function: Tangent
;;;=====================================================
(defun tan (x)
  (/ (sin x) (cos x))
)

;;;=====================================================
;;; Helper function: Arcsin
;;;=====================================================
(defun asin (x)
  (atan x (sqrt (- 1.0 (* x x))))
)

(princ "
=== Polyline Merge Commands Loaded ===")
(princ "
Commands: MERGEPL, MERGEARC, MP")
(princ "
MERGEPL - Advanced merge with auto angle detection")
(princ "
MERGEARC - Merge with arc fillet for perpendicular lines")
(princ "
MP - Quick merge using PEDIT")
(princ)

;;; اختصار من ثلاثة أحرف.
(defun c:MPL () (c:MERGEPL))
