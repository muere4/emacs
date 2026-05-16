;;; muere-modeline --- modeline -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-utility)

(defun muere/mode-line-render (left right)
  "Renderiza el modeline con LEFT y RIGHT alineados."
  (let* ((available-width (- (window-width) (length left) 3)))
    (format (format " %%s %%%ds " available-width) left right)))

(setq-default
 mode-line-format
 '((:eval
    (muere/mode-line-render
     (concat
      (propertize (format-mode-line (buffer-name)) 'face 'bold)
      " - "
      (format-mode-line mode-name)
      " - "
      (muere/replace-home default-directory))
     (format-mode-line
      '(line-number-mode
        (" line %l"
         (column-number-mode " column %c"))))))))

(provide 'muere-modeline)
;;; muere-modeline.el ends here
