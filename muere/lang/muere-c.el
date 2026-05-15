;;; muere-c --- C/C++ support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-hydra)
(require 'muere-lsp)

(defhydra muere/ide-c (:color teal :hint nil)
  "Dispatcher > C/C++ IDE"
  ("<f12>" keyboard-escape-quit)
  ("S" lsp-workspace-restart "restart lsp")
  ("i" lsp-execute-code-action "code action")
  ("b" (compile "make") "build")
  ("e" flycheck-next-error "goto error")
  ("r" lsp-rename "rename")
  ("D" xref-find-definitions "goto def")
  ("R" xref-find-references "goto refs"))

(defun muere/c-setup ()
  "Configuración para programación en C/C++."
  (c-set-style "linux")
  (hl-line-mode)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local c-basic-offset 4)
  (setq-local muere/contextual-ide #'muere/ide-c/body)
  ;; clangd via lsp — está en modules/system/dev/cpp.nix
  (lsp-deferred))

(add-hook 'c-mode-hook   #'muere/c-setup)
(add-hook 'c++-mode-hook #'muere/c-setup)

(provide 'muere-c)
;;; muere-c.el ends here
