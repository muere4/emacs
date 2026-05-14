;;; init --- initialization -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(setq
 gc-cons-threshold 402653184
 gc-cons-percentage 0.6)
(defvar muere/file-name-handler-alist)
(setq muere/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq inhibit-startup-echo-area-message "muere")

(setq-default
 indent-tabs-mode nil
 bidi-display-reordering nil
 cursor-in-non-selected-windows nil)

(setq
 max-specpdl-size 5000
 shell-file-name "/run/current-system/sw/bin/bash"
 make-backup-files nil
 auto-save-default nil
 initial-major-mode 'eshell-mode
 initial-scratch-message nil
 completion-at-point-functions nil
 user-full-name "muere"
 custom-file "/dev/null"
 recentf-max-saved-items nil
 recentf-keep '(recentf-keep-default-predicate remote-file-p)
 x-wait-for-event-timeout nil
 confirm-kill-emacs 'y-or-n-p
 disabled-command-function nil
 password-cache t
 password-cache-expiry 3600
 inhibit-startup-message t
 visible-cursor nil
 scroll-step 1
 focus-follows-mouse nil
 sentence-end-double-space nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(blink-cursor-mode -1)
(show-paren-mode -1)
(tooltip-mode -1)
(global-hl-line-mode)
(column-number-mode)
(recentf-mode)

(defadvice keyboard-escape-quit
    (around keyboard-escape-quit-dont-close-windows activate)
  (let ((buffer-quit-function (lambda () ())))
    ad-do-it))

(defun mode-line-render (left right)
  "Renderizar LEFT y RIGHT en el mode line."
  (let* ((available-width (- (window-width) (length left) 3)))
    (format (format " %%s %%%ds " available-width) left right)))

(setq-default
 mode-line-format
 `((:eval
    (mode-line-render
     (concat
      (propertize (format-mode-line (buffer-name)) 'face 'bold)
      " - "
      (format-mode-line mode-name)
      " - "
      (muere/replace-home default-directory))
     (format-mode-line
      '(line-number-mode (" line %l" (column-number-mode " column %c"))))))))

(add-to-list 'load-path "~/.emacs.d/muere")
(require 'muere-core)
(require 'muere-ui)
(require 'muere-editor)
(require 'muere-media)
(require 'muere-lang)

(setq comint-prompt-read-only t)

(evil-define-key 'insert comint-mode-map
  (kbd "<up>")   #'comint-previous-input
  (kbd "<down>") #'comint-next-input)

(defun muere/comint-eof ()
  "Enviar EOF y matar el buffer."
  (interactive)
  (comint-send-eof)
  (let ((kill-buffer-query-functions nil))
    (kill-buffer)))

(define-key comint-mode-map (kbd "C-l") #'comint-clear-buffer)
(define-key comint-mode-map (kbd "C-d") #'muere/comint-eof)

(define-key special-mode-map    (kbd "q") 'muere/dispatcher)
(define-key compilation-mode-map (kbd "q") 'muere/dispatcher)
(define-key grep-mode-map        (kbd "q") 'muere/dispatcher)

(use-package hexl
  :config
  (define-key hexl-mode-map (kbd "M-h") #'windmove-left)
  (define-key hexl-mode-map (kbd "M-l") #'windmove-right)
  (define-key hexl-mode-map (kbd "M-k") #'windmove-up)
  (define-key hexl-mode-map (kbd "M-j") #'windmove-down))

(global-set-key (kbd "M-h") #'windmove-left)
(global-set-key (kbd "M-l") #'windmove-right)
(global-set-key (kbd "M-k") #'windmove-up)
(global-set-key (kbd "M-j") #'windmove-down)

(setenv "INSIDE_EMACS" (format "%s,comint" emacs-version))

(server-start)

(setq
 gc-cons-threshold 16777216
 gc-cons-percentage 0.1
 file-name-handler-alist muere/file-name-handler-alist)

(provide 'init)
;;; init.el ends here
