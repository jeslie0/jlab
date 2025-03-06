;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)
(package-install 'org-ref)
(package-install 'org-roam)
(require 'ox-publish)
(require 'org-ref)
(require 'org-roam)


;; Very simplified version of org-ref-export-to from org-ref-export.el
;; that export to filename
(defun org-ref-export-to-file-nomarks-noopen
    (backend filename &optional async subtreep visible-only body-only info)
    (org-export-with-buffer-copy
     (org-export-expand-include-keyword)
     (org-ref-process-buffer backend subtreep)
     (org-export-to-file backend filename
             async subtreep visible-only
             body-only info)
     ))

;; org-html-publish-to-html from ox-html.el adapted to org-ref
;; Instead of org-export-to-file calls org-ref-export-to-file-nomarks-noopen
(defun org-ref-html-publish-to-html (plist filename pub-dir)
  (unless (or (not pub-dir) (file-exists-p pub-dir)) (make-directory pub-dir t))
  ;; Check if a buffer visiting FILENAME is already open.
  (let* ((org-inhibit-startup t)
     (visiting (find-buffer-visiting filename))
     (work-buffer (or visiting (find-file-noselect filename))))
    (unwind-protect
      (with-current-buffer work-buffer
        (let ((output (org-export-output-file-name ".html" nil pub-dir)))
          (org-ref-export-to-file-nomarks-noopen 'html output
            nil nil nil (plist-get plist :body-only)
            (org-combine-plists
             plist
             `(:crossrefs
               ,(org-publish-cache-get-file-property
                 ;; Normalize file names in cache.
                 (file-truename filename) :crossrefs nil t)
               :filter-final-output
               (org-publish--store-crossrefs
                org-publish-collect-index
                ,@(plist-get plist :filter-final-output))))))))))


(setq org-publish-project-alist
      (list (list "jlab"
                  :recursive t
                  :auto-sitemap t
                  :base-directory "content"
                  :publishing-directory "public"
                  :publishing-function 'org-ref-html-publish-to-html
                  :with-author nil
                  :with-creator nil
                  :with-toc t
                  :section-numbers t
                  :time-stamp-file nil
                  :async t
                  )))

(setq org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil
      org-html-with-latex 'html
      bibtex-completion-bibliography "~/texmf/bibtex/bib/bibliography.bib"
      org-latex-to-html-convert-command (format "%s %s" (dired-make-absolute "resources/make-tex-frag.sh") "%i")
      org-html-prefer-user-labels t
      org-roam-directory (dired-make-absolute "content")
      )

(setq
 org-html-preamble "<navbar><img src='favicon.ico' class='site-logo'></img></navbar>"
 org-html-head (mapconcat
                'identity
                '("<link rel='stylesheet' href='assets/css/nlab.css'></link>")
                "\n"
                ))

(message (dired-make-absolute "content"))
(org-publish-all t)
