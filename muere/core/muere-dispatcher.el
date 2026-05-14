;;; muere-dispatcher --- contextual interfaces -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-evil)
(require 'muere-hydra)

(defvar-local muere/contextual-ide
  (lambda () (interactive) (message "No IDE support in current mode")))
(defvar-local muere/contextual-lookup 'man)
(defvar-local muere/contextual-quit nil)
(defvar-local muere/contextual-write nil)
(defvar-local muere/contextual-kill nil)

(setq evil-lookup-func
      (lambda () (call-interactively muere/contextual-lookup)))

(defun muere/evil-quit-wrapper (f &rest args)
  "Wrapper de F (evil-quit), pasando ARGS."
  (if muere/contextual-quit
      (call-interactively muere/contextual-quit)
    (apply f args)))
(advice-add 'evil-quit :around 'muere/evil-quit-wrapper)

(defun muere/evil-write-wrapper (f &rest args)
  "Wrapper de F (evil-write), pasando ARGS."
  (if muere/contextual-write
      (call-interactively muere/contextual-write)
    (apply f args)))
(advice-add 'evil-write :around 'muere/evil-write-wrapper)

(defun muere/kill-this-buffer ()
  "Matar el buffer actual o llamar muere/contextual-kill."
  (interactive)
  (if muere/contextual-kill
      (call-interactively muere/contextual-kill)
    (kill-this-buffer)))

(defun muere/switch-to-scratch ()
  "Cambiar al buffer *scratch*."
  (interactive)
  (if (get-buffer "*scratch*")
      (switch-to-buffer "*scratch*")
    (progn
      (switch-to-buffer (get-buffer-create "*scratch*"))
      (cd "~")
      (eshell-mode))))

;; ─── Sub-dispatchers ──────────────────────────────────────────────────────────

(defhydra muere/repl-dispatcher (:color teal :hint nil)
  "Dispatcher > REPLs"
  ("<f12>" keyboard-escape-quit)
  ("l" ielm "elisp")
  ("x" nix-repl "nix")
  ("y" (switch-to-buffer (make-comint "Python REPL" "python3" nil)) "python"))

(defhydra muere/layout-dispatcher (:color teal :hint nil)
  "Dispatcher > Layout"
  ("<f12>" keyboard-escape-quit)
  ("l" muere/reload-eyebrowse-config "load")
  ("s" muere/save-eyebrowse-config "save")
  ("d" muere/lock-window "dedicated"))

(defhydra muere/stream-dispatcher (:color teal :hint nil)
  "Dispatcher > Stream"
  ("<f12>" keyboard-escape-quit))

(defhydra muere/dispatcher (:color teal :hint nil)
  "Dispatcher"
  ("<f12>"   keyboard-escape-quit)
  ("<print>" muere/screenshot)
  (":"       selector-M-x)
  ("?"       selector-apropos)
  ("!"       muere/run-external-command)
  ("\""      evil-window-vsplit)
  ("%"       evil-window-split)
  ("SPC"     muere/kill-this-buffer)
  ("^"       (eyebrowse-create-window-config))
  (","       eyebrowse-prev-window-config)
  ("."       eyebrowse-next-window-config)
  ("<"       eyebrowse-prev-window-config)
  (">"       eyebrowse-next-window-config)
  ("/"       muere/selector-rg)
  ("+"       (text-scale-increase 1)  :color red)
  ("="       (text-scale-increase 1)  :color red)
  ("-"       (text-scale-increase -1) :color red)
  ("_"       (text-scale-increase -1) :color red)
  ("0"       muere/switch-to-scratch)
  ("1"       eyebrowse-switch-to-window-config-0)
  ("2"       eyebrowse-switch-to-window-config-1)
  ("3"       eyebrowse-switch-to-window-config-2)
  ("4"       eyebrowse-switch-to-window-config-3)
  ("5"       eyebrowse-switch-to-window-config-4)
  ("6"       eyebrowse-switch-to-window-config-5)
  ("7"       eyebrowse-switch-to-window-config-6)
  ("8"       eyebrowse-switch-to-window-config-7)
  ("9"       eyebrowse-switch-to-window-config-8)
  ("a"       muere/agenda-dispatcher/body "agenda")
  ("b"       muere/browser-dispatcher/body "web")
  ("B"       muere/visit-bookmark)
  ("f"       selector-for-files "file")
  ("F"       (dired "."))
  ("h"       muere/repl-dispatcher/body "repl")
  ("H"       ielm)
  ("i"       (call-interactively muere/contextual-ide) "lang")
  ("I"       imenu)
  ("j"       rename-buffer)
  ("J"       flycheck-next-error)
  ("k"       evil-quit)
  ("K"       eyebrowse-close-window-config)
  ("l"       muere/layout-dispatcher/body)
  ("L"       muere/reload-eyebrowse-config)
  ("m"       muere/music-dispatcher/body)
  ("o"       muere/navigate "buf")
  ("O"       selector-for-buffers)
  ("p"       projectile-switch-project "proj")
  ("P"       muere/password)
  ("q"       muere/previous-buffer)
  ("Q"       eyebrowse-last-window-config)
  ("r"       muere/stream-dispatcher/body "stream")
  ("s"       muere/shell-here "shell")
  ("S"       projectile-run-eshell)
  ("t"       muere/term-here "term")
  ("v"       muere/vc-dispatcher/body "vc")
  ("V"       magit-status)
  ("w"       evil-write)
  ("x"       shrink-window-horizontally  :color red)
  ("X"       enlarge-window-horizontally :color red)
  ("y"       shrink-window               :color red)
  ("Y"       enlarge-window              :color red)
  ("z"       eyebrowse-switch-to-window-config)
  ("Z"       eyebrowse-rename-window-config))

(defun muere/dispatcher ()
  "Abrir menú Dispatcher."
  (interactive)
  (let ((hydra-is-helpful nil))
    (call-interactively 'muere/dispatcher/body)))

(defun muere/dispatcher-silent ()
  "Abrir menú Dispatcher silenciosamente."
  (interactive)
  (let ((hydra-is-helpful nil))
    (call-interactively 'muere/dispatcher/body)))

(provide 'muere-dispatcher)
;;; muere-dispatcher.el ends here
