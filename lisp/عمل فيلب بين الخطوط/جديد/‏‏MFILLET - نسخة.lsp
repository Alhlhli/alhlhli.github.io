;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: FIL
;;; الملف الأصلي: ‏‏MFILLET - نسخة.lsp
(defun c:FilletAllLinesAndPolylines ( / ss radius line1 line2 i)
  (princ "\nSelect all the lines and polylines you want to fillet: ")
  (setq ss (ssget '((0 . "LINE, POLYLINE")))) ; تحديد جميع الخطوط والبولي لاين
  (if ss
    (progn
      (setq radius (getreal "\nEnter fillet radius: ")) ; طلب إدخال نصف القطر
      (setq i 0)
      (while (< i (1- (sslength ss))) ; تكرار العملية لجميع الكائنات
        (setq line1 (ssname ss i)) ; الحصول على الكائن الأول
        (setq line2 (ssname ss (1+ i))) ; الحصول على الكائن التالي
        (command "FILLET" "R" radius line1 line2) ; تنفيذ أمر FILLET
        (setq i (1+ i)) ; الانتقال إلى العنصر التالي
      )
    )
    (princ "\nNo lines or polylines found in the drawing.") ; إذا لم يتم العثور على خطوط أو بولي لاين
  )
  (princ) ; إنهاء البرنامج
)

;;; اختصار من ثلاثة أحرف.
(defun c:FIL () (c:FilletAllLinesAndPolylines))
