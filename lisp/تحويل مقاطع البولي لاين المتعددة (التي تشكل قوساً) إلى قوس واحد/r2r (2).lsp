;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: R2A
;;; الملف الأصلي: r2r (2).lsp
;;; ============================================================
;;; R2R.lsp  -  تحويل مقاطع البولي لاين المتعددة (التي تشكل قوساً) إلى قوس واحد
;;; الأمر: R2R
;;; يعمل على LWPOLYLINE ويحافظ على نفس البولي لاين (لا يكسر ولا يفصل)
;;; ============================================================
(vl-load-com)

;; نسبة السماح (من نصف القطر) لاعتبار النقاط واقعة على نفس الدائرة
;; كبّرها قليلاً (مثلاً 0.005) إذا كان القوس غير دقيق
(setq r2r:*tol* 0.0005)

;; أقل عدد مقاطع مطلوب لاعتبارها قوساً (المقاطع القليلة الطويلة تبقى كما هي)
(setq r2r:*minseg* 5)

;; أكبر زاوية مركزية للمقطع الواحد بالراديان (15 درجة) - يمنع تحويل الخطوط الطويلة إلى قوس
(setq r2r:*maxstep* 0.2618)

;; مسافة بين نقطتين
(defun r2r:dist (a b)
  (sqrt (+ (expt (- (car a) (car b)) 2) (expt (- (cadr a) (cadr b)) 2)))
)

;; تطبيع الزاوية إلى المجال 0 .. 2pi
(defun r2r:norm (a / tp)
  (setq tp (* 2.0 pi))
  (setq a (rem a tp))
  (if (< a 0.0) (+ a tp) a)
)

(defun r2r:zero (b) (< (abs b) 1e-9))

;; مركز الدائرة المارة بثلاث نقاط (nil إذا كانت على استقامة واحدة)
(defun r2r:circ (a b c / bx by cx cy d b2 c2)
  (setq bx (- (car b) (car a))  by (- (cadr b) (cadr a))
        cx (- (car c) (car a))  cy (- (cadr c) (cadr a))
        b2 (+ (* bx bx) (* by by))
        c2 (+ (* cx cx) (* cy cy))
        d  (* 2.0 (- (* bx cy) (* by cx))))
  (if (< (abs d) (* 1e-10 (+ b2 c2)))
    nil
    (list (+ (car a) (/ (- (* cy b2) (* by c2)) d))
          (+ (cadr a) (/ (- (* bx c2) (* cx b2)) d)))
  )
)

;; فحص إمكانية استبدال النقاط i..j بقوس واحد
;; ترجع (cx cy R bulge) أو nil
(defun r2r:fit (pts i j / pa pm pb c r lim s dir a0 k p dk dprev ok)
  (setq pa (nth i pts)
        pb (nth j pts)
        pm (nth (/ (+ i j) 2) pts)
        c  (r2r:circ pa pm pb))
  (if c
    (progn
      (setq r   (r2r:dist c pa)
            lim (* r2r:*tol* r)
            ok  T
            s   (- (* (- (car pb) (car pa)) (- (cadr pm) (cadr pa)))
                   (* (- (cadr pb) (cadr pa)) (- (car pm) (car pa))))
            dir (if (< s 0.0) 1.0 -1.0)
            a0  (angle c pa)
            dprev 0.0
            dk 0.0
            k i)
      (while (and ok (<= k j))
        (setq p (nth k pts))
        ;; النقطة يجب أن تقع على الدائرة
        (if (> (abs (- (r2r:dist c p) r)) lim) (setq ok nil))
        ;; طول الوتر يجب ألا يتجاوز الزاوية المركزية القصوى (تمييز القوس عن الخطوط الطويلة)
        (if (and ok (< k j)
                 (> (r2r:dist p (nth (1+ k) pts))
                    (* 2.0 r (sin (/ r2r:*maxstep* 2.0)))))
          (setq ok nil))
        ;; الترتيب على القوس يجب أن يكون متصاعداً
        (if ok
          (progn
            (setq dk (r2r:norm (* dir (- (angle c p) a0))))
            (if (and (> k i) (< dk (- dprev 1e-6))) (setq ok nil))
            (setq dprev dk)))
        (setq k (1+ k))
      )
      (if (and ok (> dk 1e-6) (< dk 6.2))
        (list (car c) (cadr c) r (* dir (/ (sin (/ dk 4.0)) (cos (/ dk 4.0)))))
        nil)
    )
    nil
  )
)

;; دمج الرؤوس المتطابقة
(defun r2r:clean (vs / out v)
  (foreach v vs
    (if (and out (< (r2r:dist (car v) (car (car out))) 1e-6))
      (setq out (cons (list (car (car out)) (cadr (car out)) (caddr v) (cadddr v))
                      (cdr out)))
      (setq out (cons v out))))
  (reverse out)
)

;; تحليل بيانات الكيان إلى (رأس رؤوس ذيل)
(defun r2r:parse (ed / hdr vs tl c v g)
  (foreach g ed
    (setq c (car g))
    (cond
      ((= c 10) (setq vs (cons (list (cdr g) nil nil 0.0) vs)))
      ((and vs (= c 40))
       (setq v (car vs)
             vs (cons (list (car v) (cdr g) (caddr v) (cadddr v)) (cdr vs))))
      ((and vs (= c 41))
       (setq v (car vs)
             vs (cons (list (car v) (cadr v) (cdr g) (cadddr v)) (cdr vs))))
      ((and vs (= c 42))
       (setq v (car vs)
             vs (cons (list (car v) (cadr v) (caddr v) (cdr g)) (cdr vs))))
      ((and vs (= c 91)) nil)
      (vs (setq tl (cons g tl)))
      (T (setq hdr (cons g hdr)))
    )
  )
  (list (reverse hdr) (reverse vs) (reverse tl))
)

;; مجموعات DXF لرأس واحد
(defun r2r:vg (v)
  (append
    (list (cons 10 (car v)))
    (if (cadr v) (list (cons 40 (cadr v))))
    (if (caddr v) (list (cons 41 (caddr v))))
    (if (not (r2r:zero (cadddr v))) (list (cons 42 (cadddr v))))
  )
)

;; معالجة قائمة الرؤوس: ترجع (الرؤوس_الجديدة عدد_الأقواس)
(defun r2r:process (vs / n pts bul i j f best out cnt ok v)
  (setq vs  (r2r:clean vs)
        n   (length vs)
        pts (mapcar 'car vs)
        bul (mapcar 'cadddr vs)
        i 0
        cnt 0)
  (while (< i n)
    (setq best nil)
    (if (and (< (+ i r2r:*minseg*) n)
             (r2r:zero (nth i bul))
             (r2r:zero (nth (1+ i) bul)))
      (progn
        (setq j (+ i r2r:*minseg*) ok T)
        (while (and ok (< j n))
          (if (and (r2r:zero (nth (1- j) bul))
                   (setq f (r2r:fit pts i j)))
            (setq best (cons j f)
                  j (1+ j))
            (setq ok nil)))))
    (if best
      (progn
        (setq v (nth i vs)
              j (car best))
        ;; رأس البداية يأخذ قيمة الانحناء، وتُحذف الرؤوس الوسطى
        (setq out (cons (list (car v) (cadr v)
                              (caddr (nth (1- j) vs))
                              (nth 4 best))
                        out))
        (setq i j
              cnt (1+ cnt)))
      (progn
        (setq out (cons (nth i vs) out))
        (setq i (1+ i)))
    )
  )
  (list (reverse out) cnt)
)

;; ------------------------------------------------------------
;; الأمر الرئيسي
;; ------------------------------------------------------------
(defun c:r2r (/ ss k en ed pr res nv cnt tot doc)
  (setq ss (ssget '((0 . "LWPOLYLINE"))))
  (if ss
    (progn
      (setq doc (vla-get-activedocument (vlax-get-acad-object))
            tot 0
            k 0)
      (vla-startundomark doc)
      (repeat (sslength ss)
        (setq en  (ssname ss k)
              ed  (entget en)
              pr  (r2r:parse ed)
              res (r2r:process (cadr pr))
              nv  (car res)
              cnt (cadr res))
        (if (> cnt 0)
          (progn
            (entmod
              (append
                (mapcar '(lambda (g) (if (= (car g) 90) (cons 90 (length nv)) g))
                        (car pr))
                (apply 'append (mapcar 'r2r:vg nv))
                (caddr pr)))
            (entupd en)
            (setq tot (+ tot cnt))))
        (setq k (1+ k))
      )
      (vla-endundomark doc)
      (princ (strcat "\nR2R: arcs created = " (itoa tot)))
    )
    (princ "\nR2R: no LWPOLYLINE selected.")
  )
  (princ)
)

(princ "\nR2R loaded. Type R2R to run.")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:R2A () (c:r2r))
