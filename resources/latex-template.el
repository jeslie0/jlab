(defun insert-latex-snippet (snippet)
  (let ((template  "\\documentclass{article}
\\usepackage[pdftex,active,tightpage]{preview}
\\usepackage{amsmath}
\\usepackage{amsthm}
\\usepackage{amsfonts}
\\usepackage{amssymb}
\\usepackage{bbm}
\\usepackage{mathrsfs}
\\usepackage{mathtools}
\\usepackage{physics}
\\usepackage{tikz-cd}
\\usepackage{tikz}

\\begin{document}
\\begin{preview}
%s
\\end{preview}
\\end{document}"))
    (format template snippet)))

(defun latex-to-svg (latex-code)
  (let* ((tmp-dir "/tmp/texfrag/")
         (hash (md5 latex-code))
         (tex-file (concat tmp-dir hash ".tex"))
         (dvi-file (concat tmp-dir hash ".dvi"))
         (svg-file (concat tmp-dir hash ".svg")))
    (if (file-exists-p svg-file)
        (with-temp-buffer
          (insert-file-contents svg-file)
          (write-region (buffer-string) nil "/dev/stdout"))
      (unless (file-directory-p tmp-dir)
        (make-directory tmp-dir t))
      (with-temp-file tex-file
        (insert latex-code))
      (call-process "lualatex" nil nil nil
                    "--interaction=nonstopmode"
                    "--shell-escape"
                    "--output-format=dvi"
                    (concat "--output-directory=" tmp-dir)
                    tex-file)
      (call-process "dvisvgm" nil nil nil
                    dvi-file "-n" "-b" "min" "-c" "1.5" "-o" svg-file)
      (with-temp-buffer
                 (insert-file-contents svg-file)
                 (write-region (buffer-string) nil "/dev/stdout")))))

(let ((snippet (car command-line-args-left)))
  (latex-to-svg ( insert-latex-snippet snippet)))
