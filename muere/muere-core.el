;;; muere-core --- core functionality -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(add-to-list 'load-path "~/.emacs.d/muere/core")
(require 'muere-package)
(require 'muere-utility)
(require 'muere-evil)
(require 'muere-hydra)
(require 'muere-dispatcher)
(require 'muere-projectile)
(require 'muere-selector)
(require 'muere-vc)

(provide 'muere-core)
;;; muere-core.el ends here
