;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: IDW
;;; الملف الأصلي: InsertFolderDWGs.LSP
(defun C:InsertFolderDWGs ( / folderPath dist files pt fullPath shell folderObj selFolder )
  (vl-load-com)
  ;; فتح نافذة لاختيار المجلد
  (setq shell (vlax-get-or-create-object "Shell.Application"))
  (setq folderObj (vlax-invoke shell 'BrowseForFolder 0 "اختر المجلد الذي يحتوي على ملفات DWG:" 0 ""))
  
  (if folderObj
    (progn
      (setq selFolder (vlax-get-property folderObj 'Self))
      (setq folderPath (vlax-get-property selFolder 'Path))
      (vlax-release-object selFolder)
      (vlax-release-object folderObj)

      ;; التأكد من صحة مسار المجلد
      (if (not (wcmatch folderPath "*\\"))
        (setq folderPath (strcat folderPath "\\"))
      )

      ;; جلب جميع ملفات الأوتوكاد في المجلد
      (setq files (vl-directory-files folderPath "*.dwg" 1))
      
      (if files
        (progn
          ;; طلب المسافة ونقطة الإدراج
          (setq dist (getdist "\nأدخل المسافة الأفقية بين كل ملف والآخر: "))
          (setq pt (getpoint "\nحدد نقطة البداية لإدراج الملف الأول: "))
          
          (if (and dist pt)
            (progn
              (setvar "CMDECHO" 0)
              (foreach file files
                (setq fullPath (strcat folderPath file))
                ;; إدراج الملف كـ Block
                (command "_.-INSERT" (strcat "\"" fullPath "\"") pt 1.0 1.0 0.0)
                ;; تحديث نقطة الإدراج للملف التالي (إزاحة على محور X)
                (setq pt (list (+ (car pt) dist) (cadr pt) (caddr pt)))
              )
              (setvar "CMDECHO" 1)
              (princ (strcat "\nتم إدراج " (itoa (length files)) " ملف(ملفات) بنجاح."))
            )
            (princ "\nتم الإلغاء.")
          )
        )
        (princ "\nلم يتم العثور على ملفات DWG في المجلد المختار.")
      )
    )
    (princ "\nلم يتم اختيار مجلد.")
  )
  (if shell (vlax-release-object shell))
  (princ)
)
(princ "\nقم بكتابة الأمر InsertFolderDWGs لتشغيل الليسب.")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:IDW () (c:InsertFolderDWGs))
