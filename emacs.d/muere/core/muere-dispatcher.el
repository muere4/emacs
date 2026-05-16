;;; muere-dispatcher --- contextual interfaces -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)
(require 'muere-evil)
(require 'muere-hydra)

;; ─── Sistema de contexto ───────────────────────────────────
(defvar-local muere/contextual-ide
  (lambda () (interactive) (message "No IDE en este modo")))
(defvar-local muere/contextual-lookup 'man)
(defvar-local muere/contextual-quit nil)
(defvar-local muere/contextual-write nil)
(defvar-local muere/contextual-kill nil)

(setq evil-lookup-func (lambda () (call-interactively muere/contextual-lookup)))

;; ─── Integración con evil ──────────────────────────────────
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
(defhydra muere/repl-dispatcher (:color teal)
  "Dispatcher > REPLs"
  ("<f12>" keyboard-escape-quit "salir")
  ("l" ielm "elisp"))

;; ─── Dispatcher principal ──────────────────────────────────
(defhydra muere/dispatcher (:color teal)
  "Dispatcher"
  ("<f12>" keyboard-escape-quit "salir")

  ;; Ventanas y buffers
  ("SPC" muere/kill-this-buffer "cerrar buf")
  ("\"" evil-window-vsplit "vsplit")
  ("%" evil-window-split "split")
  ("0" muere/switch-to-scratch "scratch")

  ;; Zoom de texto
  ("+" (text-scale-increase 1) "zoom +" :color red)
  ("=" (text-scale-increase 1) "zoom +" :color red)
  ("-" (text-scale-increase -1) "zoom -" :color red)

  ;; IDE contextual
  ("i" (call-interactively muere/contextual-ide) "ide")

  ;; REPLs
  ("h" muere/repl-dispatcher/body "repl")
  ("H" ielm "ielm")

  ;; Write/quit
  ("w" evil-write "write")
  ("k" evil-quit "quit")

  ;; Archivos y buffers
  ("f" selector-for-files "archivo")
  ("F" (dired ".") "dired")
  ("o" muere/navigate "buf")
  ("O" selector-for-buffers "buffers")

  ;; Proyecto
  ("p" projectile-switch-project "proyecto")

  ;; Shell/term
  ("s" muere/shell-here "shell")
  ("t" muere/term-here "term")

  ;; Notas y VC
  ("a" muere/agenda-dispatcher/body "notas")
  ("v" muere/vc-dispatcher/body "vc")
  ("V" magit-status "magit")

  ;; Búsqueda y comandos
  ("/" muere/selector-rg "rg")
  (":" selector-M-x "M-x")
  ("q" muere/previous-buffer "prev buf")
  ;; ("B" muere/visit-bookmark "bookmark")

  ("?" describe-key "ayuda"))

;; ─── Entry points ──────────────────────────────────────────
(defun muere/dispatcher ()
  "Abrir el dispatcher."
  (interactive)
  (call-interactively 'muere/dispatcher/body))

(defun muere/dispatcher-silent ()
  "Abrir el dispatcher sin hint."
  (interactive)
  (let ((hydra-is-helpful nil))
    (call-interactively 'muere/dispatcher/body)))

(provide 'muere-dispatcher)
;;; muere-dispatcher.el ends here
