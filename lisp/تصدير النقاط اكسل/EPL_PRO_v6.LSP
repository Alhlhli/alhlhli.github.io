;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: EPL
;;; الملف الأصلي: EPL_PRO_v6.LSP
;;; ============================================================================
;;;  EPL PRO  v6.0  -  Export survey Points & Lines
;;;  المكتب الفني AL3MER  |  أداة تصدير النقاط المساحية الاحترافية
;;;  الأمر:  EPL
;;;  rem  - يصدّر النقاط من Points/Lines/Polylines/Blocks الى عدة صيغ مساحية
;;;  rem  - يرسم النقاط نصاً أو كبلوك مع Attribute ويحفظ الاعدادات في الريجستري
;;; ============================================================================

(vl-load-com)

;; --- مفاتيح الريجستري لحفظ الاعدادات ---
(defun epl:rkey () "HKEY_CURRENT_USER\\Software\\EPL_Pro")
(defun epl:reg-w (n v) (vl-registry-write (epl:rkey) n v))
(defun epl:reg-r (n d) (cond ((vl-registry-read (epl:rkey) n)) (d)))

;; --- قائمة كل حقول الواجهة (المفتاح . اسم التخزين . الافتراضي) لحفظ/استرجاع شامل ---
(setq *epl-fields*
 '(("eb_pref" "Pref" "P") ("eb_num" "Num" "1") ("eb_step" "Step" "1")
   ("eb_h" "H" "1.0") ("eb_rot" "Rot" "0") ("eb_lay" "Lay" "SURVEY_POINTS")
   ("eb_path" "Path" "") ("eb_block" "Block" "PT_MARK")
   ("eb_dE" "dE" "0") ("eb_dN" "dN" "0") ("eb_dZ" "dZ" "0") ("eb_scale" "Scale" "1")
   ("pop_style" "Style" "0") ("pop_pad" "Pad" "0") ("pop_sys" "Sys" "0")
   ("pop_filter" "Filter" "0") ("pop_dec" "Dec" "3") ("pop_sort" "Sort" "0")
   ("tg_text" "Text" "1") ("tg_z" "Z" "1") ("tg_swap" "Swap" "0")
   ("tg_flipy" "FlipY" "0") ("tg_dedup" "Dedup" "0")
   ("tg_csv" "CSV" "1") ("tg_txt" "TXT" "0") ("tg_xyz" "XYZ" "0")
   ("tg_dat" "DAT" "0") ("tg_sdr" "SDR" "0") ("tg_html" "HTML" "0") ("tg_report" "Report" "1")
   ("tg_block" "Blockf" "0") ("tg_subfolder" "Subf" "1") ("tg_open" "Open" "1")
   ("comma" "Comma" "1") ("semi" "Semi" "0") ("space" "Space" "0") ("tab" "Tab" "0")))

;; rem - يطبّق القيم المحفوظة على كل عناصر الواجهة
(defun epl:apply-saved ()
  (foreach fld *epl-fields* (set_tile (car fld) (epl:reg-r (cadr fld) (caddr fld)))))

;; rem - يحفظ القيم الحالية لكل عناصر الواجهة في الريجستري
(defun epl:save-all ()
  (foreach fld *epl-fields* (epl:reg-w (cadr fld) (get_tile (car fld)))))

;; --- دوال مساعدة عامة ---
(defun update_swatch (id idx)
  (start_image id) (fill_image 0 0 (dimx_tile id) (dimy_tile id) idx) (end_image))

(defun browse-folder ( / shell folder p)
  (setq shell (vlax-create-object "Shell.Application"))
  (setq folder (vlax-invoke shell 'BrowseForFolder 0 "اختر مجلد الحفظ الرئيسي" 0))
  (if folder (setq p (vlax-get-property (vlax-get-property folder 'Self) 'Path)))
  (vlax-release-object shell) p)

;; rem - تصفير الرقم بعدد خانات (P5 -> P005)
(defun epl:pad (n w / s) (setq s (itoa n)) (while (< (strlen s) w) (setq s (strcat "0" s))) s)

;; rem - تحويل رقم الى حروف على نمط اعمدة الاكسل (1->A 27->AA)
(defun epl:num->alpha (n / s r)
  (setq s "")
  (while (> n 0)
    (setq r (rem (1- n) 26) s (strcat (chr (+ 65 r)) s) n (/ (- n 1 r) 26)))
  s)

;; rem - يولّد اسم النقطة حسب النمط المختار
(defun epl:name (style num pad pref)
  (cond ((= style 1) (epl:num->alpha num))
        ((= style 2) (itoa num))
        (t (strcat pref (epl:pad num pad)))))

;; rem - يحوّل احداثي الرسم الى احداثي التصدير (نظام + مقياس + عكس Y + ازاحة)
(defun epl:xform (p cs scl fy de dn dz / x y z)
  (if (= cs 1) (setq p (trans p 0 1)))                 ; rem - تحويل WCS الى UCS عند الطلب
  (setq x (* (car p) scl) y (* (cadr p) scl) z (* (caddr p) scl))
  (if fy (setq y (- y)))                               ; rem - عكس اتجاه المحور Y
  (list (+ x de) (+ y dn) (+ z dz)))                   ; rem - ازاحة الاساس E/N/Z

;; rem - مقارنة الترتيب (1=حسب الشرق 2=حسب الشمال) مع كسر التعادل بالترتيب الاصلي
(defun epl:cmp (a b)
  (cond ((= *epl-sk* 1) (if (equal (nth 1 a) (nth 1 b) 1e-8) (< (nth 0 a) (nth 0 b)) (< (nth 1 a) (nth 1 b))))
        ((= *epl-sk* 2) (if (equal (nth 2 a) (nth 2 b) 1e-8) (< (nth 0 a) (nth 0 b)) (< (nth 2 a) (nth 2 b))))
        (t (< (nth 0 a) (nth 0 b)))))

;; rem - سطر بيانات لصيغة محدّدة بفاصل (مع تبديل N/E والمنسوب)
(defun epl:fmt-line (r sep swap zreq prec / e n)
  (setq e (nth 2 r) n (nth 3 r))
  (strcat (nth 0 r) sep (rtos (if swap n e) 2 prec) sep (rtos (if swap e n) 2 prec)
          (if zreq (strcat sep (rtos (nth 4 r) 2 prec)) "")))

;; rem - حقل ثابت العرض (لصيغة SDR33)
(defun epl:fw (s w) (if (not s) (setq s "")) (while (< (strlen s) w) (setq s (strcat s " "))) (substr s 1 w))

;; ============================================================================
;;  كتّاب الصيغ
;; ============================================================================
(defun epl:w-delim (fp recs sep swap zreq prec / f h1 h2)
  (setq f (open fp "w"))
  (if swap (setq h1 "Northing" h2 "Easting") (setq h1 "Easting" h2 "Northing"))
  (write-line (strcat "Point" sep h1 sep h2 (if zreq (strcat sep "Elevation") "")) f)
  (foreach r recs (write-line (epl:fmt-line r sep swap zreq prec) f))
  (close f))

;; rem - صيغة DAT بترتيب PNEZ القياسي للمحطات الكلية (Point,Northing,Easting,Z)
(defun epl:w-dat (fp recs zreq prec / f)
  (setq f (open fp "w"))
  (foreach r recs
    (write-line (strcat (nth 0 r) "," (rtos (nth 3 r) 2 prec) "," (rtos (nth 2 r) 2 prec)
                        (if zreq (strcat "," (rtos (nth 4 r) 2 prec)) "")) f))
  (close f))

;; rem - صيغة XYZ بمسافة فاصلة (Name E N Z)
(defun epl:w-xyz (fp recs zreq prec / f)
  (setq f (open fp "w"))
  (foreach r recs
    (write-line (strcat (nth 0 r) " " (rtos (nth 2 r) 2 prec) " " (rtos (nth 3 r) 2 prec)
                        (if zreq (strcat " " (rtos (nth 4 r) 2 prec)) "")) f))
  (close f))

;; rem - صيغة SDR33 (سوكيا) - سجل احداثيات 08TP بحقول 16 خانة
;; rem  تنبيه: قد تختلف عرض الحقول حسب جهازك/برنامجك فيرجى التحقق قبل الاعتماد
(defun epl:w-sdr (fp recs prec / f)
  (setq f (open fp "w"))
  (write-line "00NMSDR33 V04-04.00 AL3MER" f)
  (write-line "10NMEPL_JOB" f)
  (write-line "06NM1.00000000" f)
  (foreach r recs
    (write-line (strcat "08TP"
                  (epl:fw (nth 0 r) 16)
                  (epl:fw (rtos (nth 3 r) 2 prec) 16)   ; rem - الشمال N
                  (epl:fw (rtos (nth 2 r) 2 prec) 16)   ; rem - الشرق E
                  (epl:fw (rtos (nth 4 r) 2 prec) 16))  ; rem - المنسوب Z
                f))
  (close f))

;; rem - تقرير احصائي نصي
(defun epl:w-report (fp recs st prec / f)
  (setq f (open fp "w"))
  (write-line "==================================================" f)
  (write-line "   تقرير احصائي - المكتب الفني AL3MER (EPL v6.0)" f)
  (write-line "==================================================" f)
  (write-line (strcat "عدد النقاط        : " (itoa (nth 0 st))) f)
  (write-line (strcat "اقل شرق  (E min)  : " (rtos (nth 1 st) 2 prec)) f)
  (write-line (strcat "اكبر شرق (E max)  : " (rtos (nth 2 st) 2 prec)) f)
  (write-line (strcat "اقل شمال (N min)  : " (rtos (nth 3 st) 2 prec)) f)
  (write-line (strcat "اكبر شمال(N max)  : " (rtos (nth 4 st) 2 prec)) f)
  (write-line (strcat "اقل منسوب(Z min)  : " (rtos (nth 5 st) 2 prec)) f)
  (write-line (strcat "اكبر منسوب(Z max) : " (rtos (nth 6 st) 2 prec)) f)
  (write-line (strcat "متوسط المنسوب     : " (rtos (nth 7 st) 2 prec)) f)
  (write-line (strcat "ابعاد المنطقة E×N : " (rtos (- (nth 2 st) (nth 1 st)) 2 prec)
                      " × " (rtos (- (nth 4 st) (nth 3 st)) 2 prec)) f)
  (close f))

;; rem - تقرير HTML احترافي مستقل بالكامل (RTL عربي بدون اي مكتبات خارجية)
(defun epl:w-html (fp recs st prec / f)
  (setq f (open fp "w"))
  (write-line "<!DOCTYPE html><html lang='ar' dir='rtl'><head><meta charset='UTF-8'>" f)
  (write-line "<meta name='viewport' content='width=device-width,initial-scale=1'>" f)
  (write-line "<title>تقرير النقاط المساحية - المكتب الفني</title><style>" f)
  (write-line "*{box-sizing:border-box;margin:0;padding:0}" f)
  (write-line "body{font-family:'Segoe UI',Tahoma,Arial,sans-serif;background:#0f172a;color:#e2e8f0;padding:24px}" f)
  (write-line ".hd{background:linear-gradient(135deg,#1e3a8a,#0891b2);padding:22px;border-radius:14px;text-align:center;margin-bottom:20px}" f)
  (write-line ".hd h1{font-size:24px;color:#fff}.hd p{color:#cbd5e1;margin-top:6px;font-size:13px}" f)
  (write-line ".cards{display:flex;flex-wrap:wrap;gap:12px;margin-bottom:20px}" f)
  (write-line ".card{flex:1;min-width:150px;background:#1e293b;border:1px solid #334155;border-radius:12px;padding:16px;text-align:center}" f)
  (write-line ".card b{display:block;font-size:22px;color:#38bdf8}.card span{font-size:12px;color:#94a3b8}" f)
  (write-line "table{width:100%;border-collapse:collapse;background:#1e293b;border-radius:12px;overflow:hidden}" f)
  (write-line "th{background:#0e7490;color:#fff;padding:10px;font-size:13px}" f)
  (write-line "td{padding:8px 10px;border-top:1px solid #334155;font-size:13px;text-align:center}" f)
  (write-line "tr:nth-child(even) td{background:#172033}" f)
  (write-line ".ft{text-align:center;color:#64748b;font-size:12px;margin-top:18px}" f)
  (write-line "</style></head><body>" f)
  (write-line "<div class='hd'><h1>تقرير النقاط المساحية</h1><p>المكتب الفني AL3MER — أداة EPL Pro v6.0</p></div>" f)
  (write-line "<div class='cards'>" f)
  (write-line (strcat "<div class='card'><b>" (itoa (nth 0 st)) "</b><span>عدد النقاط</span></div>") f)
  (write-line (strcat "<div class='card'><b>" (rtos (- (nth 2 st)(nth 1 st)) 2 2) "</b><span>الامتداد شرقاً</span></div>") f)
  (write-line (strcat "<div class='card'><b>" (rtos (- (nth 4 st)(nth 3 st)) 2 2) "</b><span>الامتداد شمالاً</span></div>") f)
  (write-line (strcat "<div class='card'><b>" (rtos (nth 7 st) 2 prec) "</b><span>متوسط المنسوب</span></div>") f)
  (write-line "</div>" f)
  (write-line "<table><tr><th>الرقم</th><th>الشرق E</th><th>الشمال N</th><th>المنسوب Z</th></tr>" f)
  (foreach r recs
    (write-line (strcat "<tr><td>" (nth 0 r) "</td><td>" (rtos (nth 2 r) 2 prec)
                        "</td><td>" (rtos (nth 3 r) 2 prec)
                        "</td><td>" (rtos (nth 4 r) 2 prec) "</td></tr>") f))
  (write-line "</table>" f)
  (write-line "<p class='ft'>تم الإنشاء بواسطة EPL Pro v6.0 — t.me/pro3mer</p>" f)
  (write-line "</body></html>" f)
  (close f))

;; ============================================================================
;;  الأمر الرئيسي
;; ============================================================================
(defun c:EPL ( / *error* old_vars acadObj doc dcl_id fn f tp
              pref num step h rot lay path blockname de dn dz scale style padw
              coordsys filt prec sortby clr zreq swap flipy dedup
              csvf txtf xyzf datf sdrf htmlf reportf textf blockf subf openf sep fstr
              ss i ent obj etype raw dp ep raw2 kk2 stp cur date folder tstamp base
              lst seen out kk idxpts ii recs k pno nm it
              cnt es ns zs minE maxE minN maxN minZ maxZ avgZ st off ipt)

  (setq acadObj (vlax-get-acad-object) doc (vla-get-ActiveDocument acadObj))

  ;; --- معالج الاخطاء لاستعادة النظام ---
  (defun *error* (msg)
    (if old_vars (mapcar 'setvar '("cmdecho" "osmode") old_vars))
    (if dcl_id (unload_dialog dcl_id))
    (vla-endundomark doc)
    (princ (strcat "\n[EPL] توقّف الأمر: " (if msg msg ""))) (princ))

  (setq old_vars (mapcar 'getvar '("cmdecho" "osmode")))
  (setvar "cmdecho" 0)

  ;; --- بناء واجهة DCL ---
  (setq fn (vl-filename-mktemp "epl.dcl") f (open fn "w"))
  (write-line "epl_pro : dialog { label = \"المكتب الفني AL3MER - تصدير النقاط المساحية v6.0\";" f)

  (write-line " : boxed_row { label = \"الترقيم والتسمية\";" f)
  (write-line "   : edit_box { label=\"البادئة:\"; key=\"eb_pref\"; edit_width=6; }" f)
  (write-line "   : edit_box { label=\"الرقم البدائي:\"; key=\"eb_num\"; edit_width=6; }" f)
  (write-line "   : edit_box { label=\"الزيادة:\"; key=\"eb_step\"; edit_width=5; }" f)
  (write-line "   : popup_list { label=\"النمط:\"; key=\"pop_style\"; width=14; }" f)
  (write-line "   : popup_list { label=\"التصفير:\"; key=\"pop_pad\"; width=14; } }" f)

  (write-line " : boxed_row { label = \"إعدادات النص في الرسم\";" f)
  (write-line "   : toggle { label=\"رسم النص\"; key=\"tg_text\"; }" f)
  (write-line "   : edit_box { label=\"الارتفاع:\"; key=\"eb_h\"; edit_width=6; }" f)
  (write-line "   : edit_box { label=\"الزاوية:\"; key=\"eb_rot\"; edit_width=6; }" f)
  (write-line "   : edit_box { label=\"الطبقة:\"; key=\"eb_lay\"; edit_width=16; }" f)
  (write-line "   : button { label=\"اللون...\"; key=\"btn_clr\"; width=10; }" f)
  (write-line "   : image { key=\"img_clr\"; width=6; height=1.4; } }" f)

  (write-line " : row {" f)
  (write-line "   : boxed_column { label=\"النظام والفلترة والترتيب\";" f)
  (write-line "     : popup_list { label=\"نظام الإحداثيات:\"; key=\"pop_sys\"; width=22; }" f)
  (write-line "     : popup_list { label=\"نوع العنصر:\"; key=\"pop_filter\"; width=22; }" f)
  (write-line "     : popup_list { label=\"الترتيب:\"; key=\"pop_sort\"; width=22; }" f)
  (write-line "     : popup_list { label=\"الدقة العشرية:\"; key=\"pop_dec\"; width=22; } }" f)
  (write-line "   : boxed_column { label=\"تحويل الإحداثيات\";" f)
  (write-line "     : edit_box { label=\"إزاحة الشرق ΔE:\"; key=\"eb_dE\"; edit_width=12; }" f)
  (write-line "     : edit_box { label=\"إزاحة الشمال ΔN:\"; key=\"eb_dN\"; edit_width=12; }" f)
  (write-line "     : edit_box { label=\"إزاحة المنسوب ΔZ:\"; key=\"eb_dZ\"; edit_width=12; }" f)
  (write-line "     : edit_box { label=\"معامل المقياس:\"; key=\"eb_scale\"; edit_width=12; } }" f)
  (write-line "   : boxed_column { label=\"خيارات الإحداثي\";" f)
  (write-line "     : toggle { label=\"تضمين المنسوب Z\"; key=\"tg_z\"; }" f)
  (write-line "     : toggle { label=\"تبديل الترتيب N/E\"; key=\"tg_swap\"; }" f)
  (write-line "     : toggle { label=\"عكس المحور Y\"; key=\"tg_flipy\"; }" f)
  (write-line "     : toggle { label=\"حذف النقاط المكررة\"; key=\"tg_dedup\"; } } }" f)

  (write-line " : row {" f)
  (write-line "   : boxed_column { label=\"صيغ التصدير\";" f)
  (write-line "     : toggle { label=\"CSV (إكسل)\"; key=\"tg_csv\"; }" f)
  (write-line "     : toggle { label=\"TXT (نص)\"; key=\"tg_txt\"; }" f)
  (write-line "     : toggle { label=\"XYZ (إحداثيات)\"; key=\"tg_xyz\"; }" f)
  (write-line "     : toggle { label=\"DAT (PNEZ)\"; key=\"tg_dat\"; }" f)
  (write-line "     : toggle { label=\"SDR33 (سوكيا)\"; key=\"tg_sdr\"; } }" f)
  (write-line "   : boxed_column { label=\"الفاصل والتقارير\";" f)
  (write-line "     : radio_row {" f)
  (write-line "       : radio_button { label=\"فاصلة ,\"; key=\"comma\"; }" f)
  (write-line "       : radio_button { label=\"منقوطة ;\"; key=\"semi\"; }" f)
  (write-line "       : radio_button { label=\"مسافة\"; key=\"space\"; }" f)
  (write-line "       : radio_button { label=\"Tab\"; key=\"tab\"; } }" f)
  (write-line "     : toggle { label=\"تقرير إحصائي TXT\"; key=\"tg_report\"; }" f)
  (write-line "     : toggle { label=\"تقرير HTML احترافي\"; key=\"tg_html\"; } }" f)
  (write-line "   : boxed_column { label=\"إدراج متقدم\";" f)
  (write-line "     : toggle { label=\"إدراج كـ Block مع Attribute\"; key=\"tg_block\"; }" f)
  (write-line "     : edit_box { label=\"اسم البلوك:\"; key=\"eb_block\"; edit_width=14; }" f)
  (write-line "     : text { label=\"البلوك يحمل رقم النقطة\"; } } }" f)

  (write-line " : boxed_column { label=\"مسار الحفظ\";" f)
  (write-line "   : row { : edit_box { key=\"eb_path\"; edit_width=48; width=52; }" f)
  (write-line "           : button { label=\"استعراض...\"; key=\"btn_path\"; width=10; } }" f)
  (write-line "   : row { : toggle { label=\"إنشاء مجلد فرعي بتاريخ اليوم\"; key=\"tg_subfolder\"; }" f)
  (write-line "           : toggle { label=\"فتح المجلد بعد الانتهاء\"; key=\"tg_open\"; } } }" f)

  (write-line " spacer;" f)
  (write-line " : row { alignment=centered;" f)
  (write-line "   : button { label=\"حفظ كافتراضي\"; key=\"btn_save\"; width=14; }" f)
  (write-line "   : button { label=\"استرجاع المحفوظ\"; key=\"btn_load\"; width=14; }" f)
  (write-line "   : button { label=\"مساعدة\"; key=\"btn_help\"; width=10; }" f)
  (write-line "   : spacer { width=2; } ok_cancel; } }" f)
  (close f)

  (setq dcl_id (load_dialog fn))
  (if (not (new_dialog "epl_pro" dcl_id)) (progn (*error* "تعذّر فتح الواجهة") (exit)))

  ;; --- ملء القوائم المنسدلة ---
  (start_list "pop_style") (mapcar 'add_list '("بادئة + رقم" "حروف A,B,C" "أرقام فقط")) (end_list)
  (start_list "pop_pad")   (mapcar 'add_list '("بدون تصفير" "خانتان 01" "ثلاث 001" "أربع 0001")) (end_list)
  (start_list "pop_sys")   (mapcar 'add_list '("WCS - النظام العالمي" "UCS - نظام المستخدم")) (end_list)
  (start_list "pop_filter")(mapcar 'add_list '("الكل" "النقاط Points" "الخطوط Lines" "البولي لاين Polylines" "البلوكات Blocks")) (end_list)
  (start_list "pop_sort")  (mapcar 'add_list '("ترتيب الاختيار" "حسب الشرق E" "حسب الشمال N")) (end_list)
  (start_list "pop_dec")   (mapcar 'add_list '("0 (متر صحيح)" "1" "2" "3 (موصى به)" "4" "5" "6")) (end_list)

  ;; --- تطبيق القيم المحفوظة ثم اللون والمسار ووضع الحقول ---
  (epl:apply-saved)
  (if (= (get_tile "eb_path") "") (set_tile "eb_path" (strcat (getenv "USERPROFILE") "\\Documents")))
  (setq clr (atoi (epl:reg-r "Clr" "1")))
  (update_swatch "img_clr" clr)
  (mode_tile "eb_block" (if (= (get_tile "tg_block") "1") 0 1))
  (mode_tile "eb_h"   (if (= (get_tile "tg_text") "1") 0 1))
  (mode_tile "eb_rot" (if (= (get_tile "tg_text") "1") 0 1))

  ;; --- برمجة الأزرار ---
  (action_tile "btn_clr"  "(if (setq clr (acad_colordlg clr)) (update_swatch \"img_clr\" clr))")
  (action_tile "btn_path" "(if (setq tp (browse-folder)) (set_tile \"eb_path\" tp))")
  (action_tile "tg_block" "(mode_tile \"eb_block\" (if (= $value \"1\") 0 1))")
  (action_tile "tg_text"  "(mode_tile \"eb_h\" (if (= $value \"1\") 0 1)) (mode_tile \"eb_rot\" (if (= $value \"1\") 0 1))")
  (action_tile "btn_save" "(epl:save-all) (epl:reg-w \"Clr\" (itoa clr)) (alert \"تم حفظ الإعدادات الحالية كافتراضية\")")
  (action_tile "btn_load" "(epl:apply-saved) (setq clr (atoi (epl:reg-r \"Clr\" \"1\"))) (update_swatch \"img_clr\" clr) (alert \"تم استرجاع الإعدادات المحفوظة\")")
  (action_tile "btn_help"
    "(alert (strcat \"دليل الاستخدام السريع:\\n\\n\"
      \"1) عبّئ الإعدادات ثم اضغط OK.\\n\"
      \"2) اختر العناصر (نقاط/خطوط/بولي لاين/بلوكات).\\n\"
      \"3) تُرقّم النقاط حسب الترتيب المختار وتُكتب الملفات.\\n\\n\"
      \"ملاحظات:\\n\"
      \"- الإزاحة والمقياس يؤثران على قيم الملف فقط لا على موضع الرسم.\\n\"
      \"- تبديل N/E يعكس ترتيب العمودين في الملف.\\n\"
      \"- صيغة SDR33 مبسّطة، يُرجى التحقق من توافقها مع جهازك.\"))")
  (action_tile "accept" "(epl:save-all) (epl:reg-w \"Clr\" (itoa clr)) (done_dialog 1)")

  ;; ============================================================================
  (if (= (start_dialog) 1)
    (progn
      ;; --- قراءة كل الإعدادات من الريجستري (حُفظت في accept) ---
      (setq pref   (epl:reg-r "Pref" "P")
            num    (atoi (epl:reg-r "Num" "1"))
            step   (max 1 (atoi (epl:reg-r "Step" "1")))
            h      (atof (epl:reg-r "H" "1.0"))
            rot    (atof (epl:reg-r "Rot" "0"))
            lay    (epl:reg-r "Lay" "SURVEY_POINTS")
            path   (epl:reg-r "Path" (strcat (getenv "USERPROFILE") "\\Documents"))
            blockname (epl:reg-r "Block" "PT_MARK")
            de     (atof (epl:reg-r "dE" "0"))
            dn     (atof (epl:reg-r "dN" "0"))
            dz     (atof (epl:reg-r "dZ" "0"))
            scale  (atof (epl:reg-r "Scale" "1"))
            style  (atoi (epl:reg-r "Style" "0"))
            padw   (nth (atoi (epl:reg-r "Pad" "0")) '(0 2 3 4))
            coordsys (atoi (epl:reg-r "Sys" "0"))
            filt   (atoi (epl:reg-r "Filter" "0"))
            prec   (atoi (epl:reg-r "Dec" "3"))
            sortby (atoi (epl:reg-r "Sort" "0"))
            zreq   (= (epl:reg-r "Z" "1") "1")
            swap   (= (epl:reg-r "Swap" "0") "1")
            flipy  (= (epl:reg-r "FlipY" "0") "1")
            dedup  (= (epl:reg-r "Dedup" "0") "1")
            csvf   (= (epl:reg-r "CSV" "1") "1")
            txtf   (= (epl:reg-r "TXT" "0") "1")
            xyzf   (= (epl:reg-r "XYZ" "0") "1")
            datf   (= (epl:reg-r "DAT" "0") "1")
            sdrf   (= (epl:reg-r "SDR" "0") "1")
            htmlf  (= (epl:reg-r "HTML" "0") "1")
            reportf(= (epl:reg-r "Report" "1") "1")
            textf  (= (epl:reg-r "Text" "1") "1")
            blockf (= (epl:reg-r "Blockf" "0") "1")
            subf   (= (epl:reg-r "Subf" "1") "1")
            openf  (= (epl:reg-r "Open" "1") "1")
      )
      (if (<= scale 0.0) (setq scale 1.0))
      (setq sep (cond ((= (epl:reg-r "Comma" "1") "1") ",")
                      ((= (epl:reg-r "Semi" "0") "1") ";")
                      ((= (epl:reg-r "Space" "0") "1") " ")
                      (t "\t")))
      (setq fstr (nth filt '("POINT,INSERT,LINE,LWPOLYLINE,POLYLINE"
                             "POINT" "LINE" "LWPOLYLINE,POLYLINE" "INSERT")))

      (vla-startundomark doc)
      (princ "\nاختر العناصر المراد تصديرها: ")
      (if (setq ss (ssget (list (cons 0 fstr))))
        (progn
          ;; --- استخراج كل نقاط الرسم (WCS) ---
          (setq raw '() i 0)
          (repeat (sslength ss)
            (setq ent (ssname ss i) obj (vlax-ename->vla-object ent) etype (vla-get-ObjectName obj))
            (cond
              ((member etype '("AcDbPoint" "AcDbBlockReference"))
                 (setq raw (cons (vlax-get obj 'InsertionPoint) raw)))
              ((= etype "AcDbLine")
                 (setq raw (cons (vlax-get obj 'EndPoint) (cons (vlax-get obj 'StartPoint) raw))))
              ((wcmatch etype "*Polyline")
                 (setq raw2 (vlax-get obj 'Coordinates) kk2 0
                       stp (if (= etype "AcDb3dPolyline") 3 2))
                 (while (< kk2 (length raw2))
                   (setq raw (cons (if (= stp 2)
                                     (list (nth kk2 raw2) (nth (1+ kk2) raw2) (vla-get-Elevation obj))
                                     (list (nth kk2 raw2) (nth (1+ kk2) raw2) (nth (+ kk2 2) raw2)))
                                   raw)
                         kk2 (+ kk2 stp))))
            )
            (setq i (1+ i)))
          (setq raw (reverse raw))

          ;; --- تحويل كل نقطة الى احداثي التصدير ---
          (setq lst '())
          (foreach dp raw
            (setq ep (epl:xform dp coordsys scale flipy de dn dz))
            (setq lst (cons (list (car ep) (cadr ep) (caddr ep) dp) lst)))   ; (e n z dpt)
          (setq lst (reverse lst))

          ;; --- حذف المكرر (اختياري) حسب قيم التصدير ---
          (if dedup
            (progn
              (setq seen '() out '())
              (foreach it lst
                (setq kk (strcat (rtos (car it) 2 prec) "|" (rtos (cadr it) 2 prec) "|" (rtos (caddr it) 2 prec)))
                (if (not (member kk seen)) (setq seen (cons kk seen) out (cons it out))))
              (setq lst (reverse out))))

          ;; --- ترقيم داخلي للترتيب الثابت ---
          (setq idxpts '() ii 0)
          (foreach it lst (setq idxpts (cons (cons ii it) idxpts) ii (1+ ii)))
          (setq idxpts (reverse idxpts))                                     ; (idx e n z dpt)

          ;; --- الترتيب (اختياري) ---
          (setq *epl-sk* sortby)
          (if (> sortby 0) (setq idxpts (vl-sort idxpts (function epl:cmp))))

          ;; --- تسمية النقاط ---
          (setq recs '() k 0)
          (foreach it idxpts
            (setq pno (+ num (* k step))
                  nm  (epl:name style pno padw pref)
                  recs (cons (list nm (nth 4 it) (nth 1 it) (nth 2 it) (nth 3 it)) recs)   ; (name dpt e n z)
                  k (1+ k)))
          (setq recs (reverse recs))

          (if recs
            (progn
              ;; --- مجلد الحفظ ---
              (setq cur (menucmd "M=$(edtime,$(getvar,date),YYYY-MO-DD)")
                    tstamp (menucmd "M=$(edtime,$(getvar,date),HH-mm-ss)"))
              (if subf
                (progn (setq folder (strcat path "\\Survey_" cur))
                       (if (not (vl-file-directory-p folder)) (vl-mkdir folder)))
                (setq folder path))
              (setq base (strcat folder "\\EPL_Points_" tstamp))

              ;; --- احصائيات ---
              (setq es (mapcar '(lambda (r) (nth 2 r)) recs)
                    ns (mapcar '(lambda (r) (nth 3 r)) recs)
                    zs (mapcar '(lambda (r) (nth 4 r)) recs)
                    cnt (length recs))
              (setq st (list cnt (apply 'min es) (apply 'max es) (apply 'min ns) (apply 'max ns)
                             (apply 'min zs) (apply 'max zs) (/ (apply '+ zs) (float cnt))))

              ;; --- كتابة الصيغ المختارة ---
              (if csvf  (epl:w-delim  (strcat base ".csv") recs sep swap zreq prec))
              (if txtf  (epl:w-delim  (strcat base ".txt") recs sep swap zreq prec))
              (if xyzf  (epl:w-xyz    (strcat base ".xyz") recs zreq prec))
              (if datf  (epl:w-dat    (strcat base ".dat") recs zreq prec))
              (if sdrf  (epl:w-sdr    (strcat base ".sdr") recs prec))
              (if reportf (epl:w-report (strcat base "_report.txt") recs st prec))
              (if htmlf (epl:w-html   (strcat base "_report.html") recs st prec))

              ;; --- إنشاء الطبقة ان لم تكن موجودة ---
              (if (not (tblsearch "LAYER" lay))
                (entmakex (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord")
                                '(100 . "AcDbLayerTableRecord") (cons 2 lay)
                                (cons 70 0) (cons 62 clr) (cons 6 "Continuous"))))

              ;; --- رسم النقاط (بلوك له اولوية على النص) ---
              (if (and blockf (not (tblsearch "BLOCK" blockname)))
                (progn
                  (entmake (list '(0 . "BLOCK") (cons 2 blockname) (cons 70 2) '(10 0.0 0.0 0.0)))
                  (entmake (list '(0 . "CIRCLE") '(10 0.0 0.0 0.0) (cons 40 (* h 0.3))))
                  (entmake (list '(0 . "ATTDEF") (cons 10 (list (* h 0.5) (* h 0.5) 0.0))
                                 (cons 40 h) (cons 1 "0") (cons 2 "PNUM") (cons 3 "Point Number") (cons 70 0)))
                  (entmake '((0 . "ENDBLK")))))

              (setq off (* h 0.4))
              (foreach r recs
                (setq dp (nth 1 r) nm (nth 0 r))
                (setq ipt (list (+ (car dp) off) (+ (cadr dp) off) (caddr dp)))
                (cond
                  (blockf
                     (entmake (list '(0 . "INSERT") (cons 66 1) (cons 2 blockname)
                                    (cons 10 dp) (cons 8 lay) (cons 62 clr)))
                     (entmake (list '(0 . "ATTRIB") (cons 10 ipt) (cons 40 h) (cons 1 nm)
                                    (cons 2 "PNUM") (cons 70 0) (cons 8 lay) (cons 62 clr)))
                     (entmake '((0 . "SEQEND"))))
                  (textf
                     (entmake (list '(0 . "TEXT") (cons 10 ipt) (cons 40 h) (cons 1 nm)
                                    (cons 50 (* rot (/ pi 180.0))) (cons 8 lay) (cons 62 clr))))
                ))

              (vla-endundomark doc)
              (if openf (startapp "explorer" folder))
              (alert (strcat "تم تصدير " (itoa cnt) " نقطة بنجاح.\nالمجلد:\n" folder)))
            (progn (vla-endundomark doc) (alert "لم يتم العثور على نقاط صالحة في العناصر المختارة."))
          )
        )
        (vla-endundomark doc)
      )
    )
  )
  (unload_dialog dcl_id) (vl-file-delete fn)
  (mapcar 'setvar '("cmdecho" "osmode") old_vars) (princ))

(princ "\nتم تحميل EPL Pro v6.0 - المكتب الفني AL3MER | اكتب  EPL  للتشغيل")
(princ)
