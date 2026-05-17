;;; muere-theme --- UI theme -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)

;; ─── UI básica ─────────────────────────────────────────────
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(set-fringe-mode 12)

(global-display-line-numbers-mode 1)
(dolist (mode '(term-mode-hook
                shell-mode-hook
                eshell-mode-hook
                pdf-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; ─── Fuentes ───────────────────────────────────────────────
(set-face-attribute 'default nil
                    :font "FiraCode Nerd Font"
                    :height 130
                    :weight 'medium)
(set-face-attribute 'variable-pitch nil
                    :font "Roboto"
                    :height 130
                    :weight 'medium)
(set-face-attribute 'fixed-pitch nil
                    :font "FiraCode Nerd Font"
                    :height 130
                    :weight 'medium)

(set-language-environment "UTF-8")

(set-fontset-font
 t 'symbol
 (font-spec
  :family "Noto Color Emoji"
  :size 18
  :weight 'normal
  :width 'normal
  :slant 'normal))

;; ─── Tema ──────────────────────────────────────────────────
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-dracula t)
  (doom-themes-org-config)
  (let ((bg-main "#282a36")
        (bg-alt  "#21222c"))
    (set-face-attribute 'vertical-border nil
                        :foreground bg-alt
                        :background bg-alt)
    (set-face-attribute 'fringe nil
                        :foreground bg-alt
                        :background bg-alt)))

;; ─── Icons ─────────────────────────────────────────────────
(use-package nerd-icons)

;; ─── Outshine ──────────────────────────────────────────────
(use-package outshine
  :config
  (add-hook 'outline-minor-mode-hook 'outshine-mode))

(provide 'muere-theme)
;;; muere-theme.el ends here
