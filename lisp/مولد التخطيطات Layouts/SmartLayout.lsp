;;; حقوق المصدر: محفوظة لأصحابها كما وردت في الملف الأصلي؛ لا يُدّعى نقل ملكيتها.
;;; المراجعة: نسخة مجمّعة مع فحص ساكن وتحسينات موضحة في دليل الأدوات.
;;; اختصار التشغيل: SLY
;;; الملف الأصلي: SmartLayout.lsp
(vl-load-com)

(defun c:SmartLayout ( / *error* acadObj doc layouts ss i ent vlaObj minPt maxPt 
                         lst data dclId dclFile item mode attrTag deleteOld prefix
                         f result lyName pmin pmax newLy width height cp paperSpace vp blkObj attr finalName type resLst idx x)
  
  (setq acadObj (vlax-get-acad-object)
        doc     (vla-get-activedocument acadObj)
        layouts (vla-get-layouts doc))

  ;;; --- دالة معالجة الأخطاء ---
  (defun *error* (msg)
    (if (and dclId (< 0 dclId)) (unload_dialog dclId))
    (if (and dclFile (findfile dclFile)) (vl-file-delete dclFile))
    (if (not (wcmatch (strcase msg t) "*break,*cancel*,*exit*"))
      (princ (strcat "\nError: " msg))
    )
    (vla-endundomark doc)
    (princ)
  )
  
  (vla-startundomark doc)

  ;;; --- 1. اختيار العناصر وتحديد حدودها ---
  (princ "\n[المكتب الفني] اختر البلوكات أو المستطيلات المطلوبة: ")
  (setq ss (ssget '((0 . "INSERT,LWPOLYLINE,POLYLINE"))))
  
  (if (not ss)
    (progn (princ "\nلم يتم اختيار أي عناصر.") (exit))
  )

  (setq lst '() i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i)
          vlaObj (vlax-ename->vla-object ent)
          i (1+ i))
    
    ;; حساب الـ Bounding Box
    (vl-catch-all-apply 'vla-getboundingbox (list vlaObj 'minPt 'maxPt))
    (if (and minPt maxPt)
      (progn
        (setq pmin (vlax-safearray->list minPt)
              pmax (vlax-safearray->list maxPt)
              type (cdr (assoc 0 (entget ent))))
        ;; تجميع البيانات: (Entity . (Type . (Pmin . Pmax)))
        (setq lst (cons (list ent type pmin pmax) lst))
      )
    )
    (setq minPt nil maxPt nil)
  )
  (setq lst (reverse lst))

  ;;; --- 2. إنشاء ملف DCL ديناميكياً ---
  (setq dclFile (vl-filename-mktemp "temp.dcl")
        f (open dclFile "w"))
  (write-line "smart_layout_dlg : dialog { label = \"مدير الـ Layouts الذكي | المكتب الفني\";" f)
  (write-line "  : row {" f)
  (write-line "    : list_box { label = \"العناصر المكتشفة ومعاينة الأسماء:\"; key = \"lb_items\"; width = 50; height = 15; }" f)
  (write-line "  }" f)
  (write-line "  : boxed_column { label = \"خيارات التسمية\";" f)
  (write-line "    : radio_row { key = \"rg_mode\";" f)
  (write-line "      : radio_button { label = \"اسم البلوك\"; key = \"rb_blk\"; value = \"1\"; }" f)
  (write-line "      : radio_button { label = \"Attribute\"; key = \"rb_attr\"; }" f)
  (write-line "      : radio_button { label = \"تلقائي يدوّي\"; key = \"rb_manual\"; }" f)
  (write-line "    }" f)
  (write-line "    : edit_box { label = \"Tag الاوتريبيوت / البادئة:\"; key = \"eb_tag\"; value = \"LAYOUT-\"; }" f)
  (write-line "  }" f)
  (write-line "  : toggle { label = \"حذف الـ Layouts القديمة إذا تطابق الاسم\"; key = \"tog_del\"; value = \"1\"; }" f)
  (write-line "  : row {" f)
  (write-line "    : button { label = \"تحديث المعاينة\"; key = \"btn_refresh\"; }" f)
  (write-line "    ok_cancel;" f)
  (write-line "  }" f)
  (write-line "}" f)
  (close f)

  ;;; --- 3. دالة تحديث قائمة المعاينة بشاشة الـ DCL ---
  (defun UpdatePreview ( / finalName blkName resLst idx)
    (setq mode (get_tile "rg_mode")
          attrTag (strcase (get_tile "eb_tag"))
          resLst '()
          idx 1)
    
    (foreach item lst
      (setq ent (car item)
            type (cadr item)
            finalName "")
      
      (cond
        ((= mode "rb_blk")
         (if (= type "INSERT")
           (setq finalName (cdr (assoc 2 (entget ent))))
           (setq finalName (strcat "Polyline-" (itoa idx)))))
        
        ((= mode "rb_attr")
         (if (= type "INSERT")
           (progn
             (setq blkObj (vlax-ename->vla-object ent)
                   finalName "")
             (if (= (vla-get-hasattributes blkObj) :vlax-true)
               (foreach attr (vlax-invoke blkObj 'GetAttributes)
                 (if (= (strcase (vla-get-tagstring attr)) attrTag)
                   (setq finalName (vla-get-textstring attr))
                 )
               )
             )
             (if (= finalName "") (setq finalName (strcat "NoAttr-" (itoa idx)))))
           (setq finalName (strcat "Polyline-" (itoa idx)))))
        
        ((= mode "rb_manual")
         (setq finalName (strcat attrTag (itoa idx))))
      )
      
      ;; تنظيف الاسم من الرموز الممنوعة
      (foreach char '("\\" "/" "?" "*" "[" "]" ":" "\"")
        (setq finalName (vl-string-translate char "_" finalName))
      )
      
      (setq resLst (cons (list finalName ent type (caddr item) (cadddr item)) resLst))
      (setq idx (1+ idx))
    )
    (setq data (reverse resLst))
    
    (start_list "lb_items")
    (foreach x data 
      (add_list (strcat (nth 0 x) " (" (nth 2 x) ")"))
    )
    (end_list)
  )

  ;;; --- 4. تشغيل شاشة الحوار ---
  (setq dclId (load_dialog dclFile))
  (if (not (new_dialog "smart_layout_dlg" dclId)) (exit))
  
  (UpdatePreview)

  (action_tile "rg_mode" "(UpdatePreview)")
  (action_tile "btn_refresh" "(UpdatePreview)")
  (action_tile "accept" "(setq deleteOld (get_tile \"tog_del\")) (done_dialog 1)")
  (action_tile "cancel" "(done_dialog 0)")
  
  (setq result (start_dialog))
  (unload_dialog dclId)
  (vl-file-delete dclFile)

  ;;; --- 5. مرحلة التنفيذ وإنشاء الـ Layouts ---
  (if (= result 1)
    (progn
      (foreach item data
        (setq lyName (nth 0 item)
              ent    (nth 1 item)
              pmin   (nth 3 item)
              pmax   (nth 4 item))
        
        (if (= deleteOld "1")
          (vl-catch-all-apply 'vla-delete (list (vla-item layouts lyName)))
        )
        
        (setq newLy (vl-catch-all-apply 'vla-add (list layouts lyName)))
        
        (if (not (vl-catch-all-error-p newLy))
          (progn
            (vla-put-activelayout doc newLy)
            (setvar "CTAB" lyName)
            
            (setq width  (- (car pmax) (car pmin))
                  height (- (cadr pmax) (cadr pmin))
                  cp (vlax-3d-point '(105.0 148.5 0.0))
            )
            
            (setq paperSpace (vla-get-paperspace doc))
            (setq vp (vla-addpviewport paperSpace cp width height))
            (vla-put-viewporton vp :vlax-true)
            
            (vla-put-mspace doc :vlax-true)
            (vla-put-activeviewport doc vp)
            (vl-cmdf "_.zoom" "_w" pmin pmax)
            (vla-put-mspace doc :vlax-false)
          )
        )
      )
      (princ (strcat "\n[نجاح] تم إنشاء وتحديث عدد (" (itoa (length data)) ") Layouts بنجاح."))
    )
  )
  
  (vla-endundomark doc)
  (princ)
)

(princ "\nتم تحميل أداة المكتب الفني بنجاح. اكتب SmartLayout للتشغيل.")
(princ)
;;; اختصار من ثلاثة أحرف.
(defun c:SLY () (c:SmartLayout))
