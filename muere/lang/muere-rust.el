;;; muere-rust --- Rust support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-hydra)
(require 'muere-lsp)

(use-package rustic
  :mode ("\\.rs\\'" . rustic-mode)
  :config
  (defhydra muere/ide-rust (:color teal :hint nil)
    "Dispatcher > Rust IDE"
    ("<f12>" keyboard-escape-quit)
    ("S" lsp-workspace-restart "restart lsp")
    ("i" lsp-execute-code-action "code action")
    ("e" flycheck-next-error "goto error")
    ("r" lsp-rename "rename")
    ("D" xref-find-definitions "goto def")
    ("R" xref-find-references "goto refs"))

  (defun muere/rust-setup ()
    "Configuración para programación en Rust."
    (flycheck-mode -1)             ; rustic tiene su propio checker integrado
    (setq-local muere/contextual-ide #'muere/ide-rust/body)
    (setq-local flycheck-check-syntax-automatically '(save mode-enabled)))

  (add-hook 'rustic-mode-hook #'muere/rust-setup))

(provide 'muere-rust)
;;; muere-rust.el ends here
