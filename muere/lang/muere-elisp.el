;;; muere-elisp --- Emacs Lisp support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-hydra)
(require 'muere-lsp)

(defhydra muere/ide-elisp (:color teal :hint nil)
  "Dispatcher > ELisp IDE"
  ("<f12>" keyboard-escape-quit)
  ("e" eval-defun "eval defun")
  ("i" eval-buffer "eval buffer")
  ("r" ielm "repl"))

(defun muere/elisp-setup ()
  "Configuración para programación en Emacs Lisp."
  (outline-minor-mode)
  (setq-local muere/contextual-ide #'muere/ide-elisp/body)
  ;; K muestra ayuda con apropos en elisp
  (setq-local muere/contextual-lookup #'selector-apropos))

(add-hook 'emacs-lisp-mode-hook #'muere/elisp-setup)
(add-hook 'ielm-mode-hook #'muere/elisp-setup)

(provide 'muere-elisp)
;;; muere-elisp.el ends here
