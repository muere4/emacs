;;; muere-nix --- Nix support -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-hydra)
(require 'muere-lsp)

;; ─── Rebuild ───────────────────────────────────────────────
(defun muere/nixos-rebuild ()
  "Ejecutar nixos-rebuild switch en un buffer de compilación."
  (interactive)
  (let ((cmd (concat "sudo nixos-rebuild switch --flake ~/nix-config#" (system-name))))
    (switch-to-buffer (compilation-start cmd))
    (rename-buffer "*nixos-rebuild*")))

;; ─── Nix mode ──────────────────────────────────────────────
(use-package nix-mode
  :mode "\\.nix\\'"
  :config
  (defhydra muere/ide-nix (:color teal :hint nil)
    "Dispatcher > Nix IDE"
    ("<f12>" keyboard-escape-quit)
    ("r" muere/nixos-rebuild "rebuild")
    ("S" lsp-workspace-restart "restart lsp")
    ("D" xref-find-definitions "goto def")
    ("R" xref-find-references "goto refs"))

  (defun muere/nix-setup ()
    "Configuración para programación en Nix."
    (setq-local muere/contextual-ide #'muere/ide-nix/body)
    ;; nixd como LSP — está en modules/system/dev/nix.nix
    (lsp-deferred))

  (add-hook 'nix-mode-hook #'muere/nix-setup))

(provide 'muere-nix)
;;; muere-nix.el ends here
