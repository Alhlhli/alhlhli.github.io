;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: ISD
;;; الملف الأصلي: ISD.lsp
;; LISP Code to Insert Multiple DWG files with Dynamic Text Height and User Start Point
;; By AL3MER  31-7-2025
;;
;; This version asks for the first block's insertion point.
;; Text height is now calculated as (spacing / 10).

;; --- Global variable to store the last used path for the Drawings option ---
(if (not *g_lastUsedPath*)
  (setq *g_lastUsedPath* nil)
)

;; ==============================================================================
;; ==                          MAIN COMMANDS                                   ==
;; ==============================================================================

;; Command: ISD (Insert Selected Drawings)
(defun c:InsertSelectedDrawingsAsBlocks (/ dwgFiles choice folderPath xOffset tempDist)
  (setq xOffset 100.0)
  (setq tempDist (getdist (strcat "\nادخل المسافة الأفقية بين البلوكات <" (rtos xOffset 2 2) ">: ")))
  (if tempDist (setq xOffset tempDist))

  (initget "Drawings Folder")
  (setq choice (getkword "\nاختر طريقة التحديد [Drawings/Folder] <Drawings>: "))
  (if (null choice) (setq choice "Drawings"))

  (cond
    ((= choice "Drawings")
     (setq dwgFiles (SelectMultipleDwgFilesManual))
     (if dwgFiles
       (PerformInsertion dwgFiles xOffset)
     )
    )
    ((= choice "Folder")
     (setq folderPath (SelectFolder))
     (if folderPath
       (progn
         (setq dwgFiles (GetAllDwgFromFolder folderPath))
         (if dwgFiles
           (PerformInsertion dwgFiles xOffset)
         )
       )
     )
    )
  )
  (if (not dwgFiles) (princ "\nلم يتم اختيار أي ملفات. تم إلغاء العملية.\n"))
  (prin1)
)

;; Short command alias for the main function
(defun c:ISD () (c:InsertSelectedDrawingsAsBlocks))

;; Command: IFD (Insert Folder Drawings)
(defun c:InsertFolderDrawingsAsBlocks (/ dwgFiles folderPath xOffset tempDist)
  (setq xOffset 100.0)
  (setq tempDist (getdist (strcat "\nادخل المسافة الأفقية بين البلوكات <" (rtos xOffset 2 2) ">: ")))
  (if tempDist (setq xOffset tempDist))

  (setq folderPath (SelectFolder))
  
  (if folderPath
    (progn
      (setq dwgFiles (GetAllDwgFromFolder folderPath))
      (if dwgFiles
        (PerformInsertion dwgFiles xOffset)
        (princ (strcat "\nلم يتم العثور على ملفات DWG في المجلد: " folderPath "\n"))
      )
    )
    (princ "\nلم يتم اختيار مجلد. تم إلغاء العملية.\n")
  )
  (prin1)
)

;; Short command alias for folder selection
(defun c:IFD () (c:InsertFolderDrawingsAsBlocks))

;; ==============================================================================
;; ==                      CORE & HELPER FUNCTIONS                           ==
;; ==============================================================================

;; Core function: Inserts all blocks first, then adds all labels.
(defun PerformInsertion (dwgFiles xOffset / insertionPoint blockName fullPath lastBlockEname insertedBlocksInfo blockInfo blockEname blockVLA min-pt max-pt textHeight textGap textInsertionPoint)
  (vl-load-com)
  
  ;; --- Ask for the starting insertion point ---
  (setq insertionPoint (getpoint "\nحدد نقطة إدراج أول بلوك: "))

  (if insertionPoint
    (progn
      (setq insertedBlocksInfo '())

      ;; --- STAGE 1: Insert all blocks ---
      (princ (strcat "\nالمرحلة 1: جاري إدراج " (itoa (length dwgFiles)) " بلوك...\n"))

      (foreach fullPath dwgFiles
        (setq blockName (vl-filename-base fullPath))
        (princ (strcat "إدراج: " (GetFileName fullPath) "\n"))
        (command "._-INSERT" (strcat "\"" fullPath "\"") insertionPoint "" "" "")
        (if (and (tblsearch "BLOCK" blockName) (setq lastBlockEname (entlast)))
            (progn
                (setq insertedBlocksInfo (cons (cons lastBlockEname blockName) insertedBlocksInfo))
                (setq insertionPoint (list (+ (car insertionPoint) xOffset) (cadr insertionPoint) (caddr insertionPoint)))
            )
            (princ (strcat "✗ فشل إدراج: " (GetFileName fullPath) "\n"))
        )
      )

      ;; --- STAGE 2: Add text labels under each inserted block ---
      (if insertedBlocksInfo
        (progn
          (princ (strcat "\nالمرحلة 2: جاري إضافة " (itoa (length insertedBlocksInfo)) " تسمية نصية...\n"))
          (foreach blockInfo (reverse insertedBlocksInfo)
            (setq blockEname (car blockInfo) blockName  (cdr blockInfo) blockVLA (vlax-ename->vla-object blockEname))
            (if (and blockVLA (= (vla-get-ObjectName blockVLA) "AcDbBlockReference"))
              (progn
                (vla-getboundingbox blockVLA 'min-pt 'max-pt)
                (setq min-pt (vlax-safearray->list min-pt) max-pt (vlax-safearray->list max-pt))
                
                ;; --- Dynamic text height and gap calculation ---
                (setq textHeight (/ xOffset 10.0))
                (setq textGap (* textHeight 2.0)) ; Gap is twice the text height for good spacing
                
                (setq textInsertionPoint (list (/ (+ (car min-pt) (car max-pt)) 2.0) (- (cadr min-pt) textGap) 0.0))
                (command "._TEXT" "_Justify" "_MC" textInsertionPoint textHeight 0 blockName)
                (princ (strcat "  + تم إضافة اسم الملف: " blockName "\n"))
              )
            )
          )
        )
      )
      
      (princ "\n*** تمت معالجة جميع الملفات بنجاح. ***\n")
      (command "._ZOOM" "_Extents")
    )
    (princ "\nتم إلغاء الأمر. لم يتم تحديد نقطة بداية.\n")
  )
)

;; Helper function to select multiple DWG files one-by-one, REMEMBERS LAST PATH
(defun SelectMultipleDwgFilesManual (/ dwgFiles selectedFile defaultPath continueSelection)
  (setq dwgFiles '())
  (setq defaultPath (if *g_lastUsedPath* (strcat *g_lastUsedPath* "\\") ""))
  
  (princ "\n*** اختر ملفات DWG واحداً تلو الآخر (اضغط Cancel للإنهاء) ***\n")
  (setq continueSelection T)

  (while continueSelection
    (setq selectedFile (getfiled 
                        (strcat "اختر ملف DWG رقم " (itoa (1+ (length dwgFiles))) " (إلغاء عند الانتهاء)") 
                        defaultPath "dwg" 0))
    (if selectedFile
      (progn
        (setq dwgFiles (cons selectedFile dwgFiles))
        (setq *g_lastUsedPath* (vl-filename-directory selectedFile))
        (setq defaultPath (strcat *g_lastUsedPath* "\\"))
      )
      (setq continueSelection nil)
    )
  )

  (if dwgFiles
    (setq dwgFiles (reverse dwgFiles))
  )
  dwgFiles
)

;; Helper function to select a folder. This version NO LONGER remembers the path.
(defun SelectFolder (/ shell folder folderItem folderPath)
  (vl-load-com)
  (if (setq shell (vlax-create-object "Shell.Application"))
    (progn
      (setq folder (vlax-invoke shell 'BrowseForFolder 0 "اختر المجلد المطلوب" 1))
      (if folder
        (progn
          (setq folderItem (vlax-get folder 'Self))
          (setq folderPath (vlax-get folderItem 'Path))
          (vlax-release-object folderItem) (vlax-release-object folder)
        )
      )
      (vlax-release-object shell)
    )
  )
  folderPath
)

;; Helper function to get all DWG files from a folder path
(defun GetAllDwgFromFolder (folderPath)
  (if (and folderPath (vl-file-directory-p folderPath))
    (mapcar '(lambda (f) (strcat folderPath "\\" f)) (vl-directory-files folderPath "*.dwg" 1))
  )
)

;; Helper function to get filename from a full path
(defun GetFileName (fullPath)
  (vl-filename-base fullPath)
)

;; Message to user on load
(princ "\n>> تم تحميل أوامر إدراج البلوكات (ISD, IFD) - إصدار محدث.")
(prin1)