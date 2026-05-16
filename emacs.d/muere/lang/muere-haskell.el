;;; muere-haskell --- Haskell support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-hydra)
(require 'muere-lsp)

(use-package lsp-haskell
  :config
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]\\dist-newstyle$" t)
  (add-to-list 'lsp-file-watch-ignored "[/\\\\]\\deps$" t)

  (defhydra muere/ide-haskell (:color teal)
    "Dispatcher > Haskell IDE"
    ("<f12>" keyboard-escape-quit "salir")
    ("S" lsp-workspace-restart "restart lsp")
    ("i" lsp-execute-code-action "code action")
    ("e" flycheck-next-error "goto error")
    ("r" lsp-rename "rename")
    ("D" xref-find-definitions "goto def")
    ("R" xref-find-references "goto refs")
    ("I" haskell-navigate-imports "goto imports")
    ("C" haskell-cabal-visit-file "goto cabal"))

  (defun muere/haskell-setup ()
    "Configuración para programación en Haskell."
    (setq-local xref-prompt-for-identifier nil)
    (setq-local muere/contextual-ide #'muere/ide-haskell/body)
    (setq-local flycheck-check-syntax-automatically '(save mode-enabled))
    (lsp-deferred))

  (add-hook 'haskell-mode-hook #'muere/haskell-setup))

(provide 'muere-haskell)
;;; muere-haskell.el ends here
