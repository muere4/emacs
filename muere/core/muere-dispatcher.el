;;; muere-dispatcher --- contextual interfaces -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-evil)
(require 'muere-hydra)

;; ─── Sistema de contexto ───────────────────────────────────
;; Variables buffer-local que cada modo puede sobreescribir
;; para personalizar el comportamiento del dispatcher
(defvar-local muere/contextual-ide
  (lambda () (interactive) (message "No IDE en este modo")))
(defvar-local muere/contextual-lookup 'man)
(defvar-local muere/contextual-quit nil)
(defvar-local muere/contextual-write nil)
(defvar-local muere/contextual-kill nil)

;; El lookup lo usa evil-K por defecto
(setq evil-lookup-func (lambda () (call-interactively muere/contextual-lookup)))

;; ─── Integración con evil ──────────────────────────────────
;; evil-quit y evil-write revisan si hay función contextual primero
(defun muere/evil-quit-wrapper (f &rest args)
  "Wrapper sobre F (evil-quit), pasando ARGS."
  (if muere/contextual-quit
      (call-interactively muere/contextual-quit)
    (apply f args)))
(advice-add 'evil-quit :around 'muere/evil-quit-wrapper)

(defun muere/evil-write-wrapper (f &rest args)
  "Wrapper sobre F (evil-write), pasando ARGS."
  (if muere/contextual-write
      (call-interactively muere/contextual-write)
    (apply f args)))
(advice-add 'evil-write :around 'muere/evil-write-wrapper)

;; ─── Utilidades ────────────────────────────────────────────
(defun muere/kill-this-buffer ()
  "Cerrar buffer actual o llamar a contextual-kill."
  (interactive)
  (if muere/contextual-kill
      (call-interactively muere/contextual-kill)
    (kill-this-buffer)))

(defun muere/switch-to-scratch ()
  "Ir al buffer scratch, creándolo en eshell-mode si no existe."
  (interactive)
  (if (get-buffer "*scratch*")
      (switch-to-buffer "*scratch*")
    (progn
      (switch-to-buffer (get-buffer-create "*scratch*"))
      (cd "~")
      (eshell-mode))))

;; ─── Sub-dispatchers ───────────────────────────────────────
(defhydra muere/repl-dispatcher (:color teal :hint nil)
  "Dispatcher > REPLs"
  ("<f12>" keyboard-escape-quit "salir")
  ("l" ielm "elisp"))
  ;; TODO: agregar cuando tengamos los módulos
  ;; ("x" nix-repl "nix")
  ;; ("y" (switch-to-buffer (make-comint "Python REPL" "python3" nil)) "python")

;; ─── Dispatcher principal ──────────────────────────────────
(defhydra muere/dispatcher (:color teal :hint nil)
  "Dispatcher"
  ("<f12>" keyboard-escape-quit)

  ;; Ventanas y buffers
  ("SPC" muere/kill-this-buffer)
  ("\"" evil-window-vsplit)
  ("%" evil-window-split)
  ("0" muere/switch-to-scratch)

  ;; Zoom de texto (:color red = no cerrar el hydra al ejecutar)
  ("+" (text-scale-increase 1) :color red)
  ("=" (text-scale-increase 1) :color red)
  ("-" (text-scale-increase -1) :color red)

  ;; IDE contextual — cada modo setea muere/contextual-ide
  ("i" (call-interactively muere/contextual-ide) "ide")

  ;; REPLs
  ("h" muere/repl-dispatcher/body "repl")
  ("H" ielm)

  ;; Write/quit
  ("w" evil-write)
  ("k" evil-quit)

  ;; TODO: descomentar cuando tengamos los módulos
  ("f" selector-for-files "archivo")
  ("F" (dired "."))
  ("o" muere/navigate "buf")
  ("O" selector-for-buffers)
  ("p" projectile-switch-project "proyecto")
  ("s" muere/shell-here "shell")
  ("t" muere/term-here "term")
  ("a" muere/agenda-dispatcher/body "notas")
  ("v" muere/vc-dispatcher/body "vc")
  ("V" magit-status)
  ("/" muere/selector-rg)
  (":" selector-M-x)
  ("q" muere/previous-buffer)
  ;; ("B" muere/visit-bookmark)

  ("?" describe-key "ayuda"))

;; ─── Entry points ──────────────────────────────────────────
(defun muere/dispatcher ()
  "Abrir el dispatcher."
  (interactive)
  (let ((hydra-is-helpful nil))
    (call-interactively 'muere/dispatcher/body)))

(defun muere/dispatcher-silent ()
  "Abrir el dispatcher sin hint."
  (interactive)
  (let ((hydra-is-helpful nil))
    (call-interactively 'muere/dispatcher/body)))

(provide 'muere-dispatcher)
;;; muere-dispatcher.el ends here
