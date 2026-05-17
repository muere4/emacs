;;; muere-modeline --- modeline -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :config
  (display-battery-mode 1)
  (setq display-time-default-load-average nil
        display-time-24hr-format t
        display-time-day-and-date t)
  (display-time-mode 1)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-icon t)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-minor-modes nil))

(provide 'muere-modeline)
;;; muere-modeline.el ends here
