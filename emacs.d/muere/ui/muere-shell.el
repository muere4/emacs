;;; muere-shell --- shell -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-utility)

;; ─── Utilidades ────────────────────────────────────────────

(defun muere/shell (dir)
  "Abrir eshell en DIR."
  (interactive)
  (let ((bufname (generate-new-buffer-name eshell-buffer-name)))
    (switch-to-buffer bufname)
    (cd dir)
    (eshell-mode)))

(defun muere/shell-here ()
  "Abrir eshell en el directorio actual."
  (interactive)
  (muere/shell default-directory))

(defun muere/truncate-eshell-buffers ()
  "Truncar todos los buffers de eshell."
  (interactive)
  (save-current-buffer
    (dolist (buffer (buffer-list t))
      (set-buffer buffer)
      (when (eq major-mode 'eshell-mode)
        (eshell-truncate-buffer)))))

(defun muere/eshell-clear ()
  "Limpiar el buffer de eshell."
  (interactive)
  (let ((inhibit-read-only t))
    (delete-all-overlays)
    (set-text-properties (point-min) (point-max) nil)
    (erase-buffer))
  (eshell-emit-prompt))

(defun muere/eshell-eof ()
  "Enviar EOF o matar el buffer."
  (interactive)
  (if eshell-process-list
      (eshell-send-eof-to-process)
    (kill-this-buffer)))

;; ─── Módulos de eshell ─────────────────────────────────────

(use-package esh-module)
(add-to-list 'eshell-modules-list 'eshell-tramp)

(use-package em-banner
  :config
  (setq eshell-banner-message ""))

(use-package em-hist
  :config
  (setq eshell-save-history-on-exit t))

;; ─── Prompt ────────────────────────────────────────────────

(use-package em-prompt
  :custom
  (eshell-prompt-regexp (rx bol "In " (one-or-more anything) ":\n"))
  :config
  (ef-themes-with-colors
    (set-face-attribute 'eshell-prompt nil
                        :foreground fg-main
                        :background bg-alt
                        :weight 'bold
                        :extend t))

  (defun muere/eshell-prompt ()
    "Prompt de eshell con directorio y rama de git."
    (let ((branch (magit-get-current-branch)))
      (concat "In " (muere/replace-home default-directory)
              (when branch
                (concat " (branch " branch ")"))
              ":\n")))

  (defun muere/eshell-previous-prompt ()
    (interactive)
    (eshell-previous-prompt 1)
    (forward-line -1))

  (defun muere/eshell-next-prompt ()
    (interactive)
    (eshell-next-prompt 1)
    (forward-line 1))

  (setq eshell-prompt-function #'muere/eshell-prompt)

  ;; Limpiar el undo history después de cada prompt
  (add-hook 'eshell-after-prompt-hook
            (lambda ()
              (setq buffer-undo-list nil buffer-undo-tree nil)
              (set-buffer-modified-p nil))))

;; ─── Eshell principal ──────────────────────────────────────

(use-package eshell
  :config
  (setq eshell-buffer-maximum-lines 5000
        eshell-output-filter-functions '(eshell-postoutput-scroll-to-bottom
                                         eshell-handle-control-codes
                                         eshell-handle-ansi-color
                                         eshell-watch-for-password-prompt))

  (defun muere/eshell-setup ()
    "Configuración de eshell."
    (show-paren-mode -1)

    (defun eshell/clear ()
      (interactive)
      (let ((inhibit-read-only t))
        (delete-all-overlays)
        (set-text-properties (point-min) (point-max) nil)
        (erase-buffer)))

    (defun eshell/open (file)
      (interactive)
      (find-file file))

    (setenv "TERM" "dumb")
    (setenv "PAGER" "cat")
    (setenv "EDITOR" "emacsclient")

    (define-key eshell-mode-map (kbd "<backtab>") 'muere/nop)
    (define-key eshell-mode-map (kbd "C-l") 'muere/eshell-clear)
    (define-key eshell-mode-map (kbd "C-c") 'eshell-interrupt-process)

    (evil-define-key 'normal eshell-mode-map (kbd "C-k") #'muere/eshell-previous-prompt)
    (evil-define-key 'motion eshell-mode-map (kbd "C-k") #'muere/eshell-previous-prompt)
    (evil-define-key 'insert eshell-mode-map (kbd "C-k") #'muere/eshell-previous-prompt)

    (evil-define-key 'normal eshell-mode-map (kbd "C-j") #'muere/eshell-next-prompt)
    (evil-define-key 'motion eshell-mode-map (kbd "C-j") #'muere/eshell-next-prompt)
    (evil-define-key 'insert eshell-mode-map (kbd "C-j") #'muere/eshell-next-prompt)

    (define-key eshell-mode-map (kbd "C-d") 'muere/eshell-eof)

    (erase-buffer)
    (eshell-emit-prompt))

  (add-hook 'eshell-mode-hook 'muere/eshell-setup)

  ;; Truncar buffers de eshell cuando Emacs esté idle
  (run-with-idle-timer 5 t 'muere/truncate-eshell-buffers))

;; ─── Direnv ────────────────────────────────────────────────
;; Integración con direnv/nix-direnv — aplica el entorno del .envrc
;; al entrar en buffers de proyectos
(use-package envrc
  :config
  (envrc-global-mode))

;; TODO: descomentar si querés completado fish en eshell
;; (use-package fish-completion
;;   :config
;;   (global-fish-completion-mode))

(provide 'muere-shell)
;;; muere-shell.el ends here
