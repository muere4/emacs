;;; muere-projectile --- project management -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)

(use-package projectile
  :custom
  ;; Usar completing-read por defecto (lo sobreescribiremos con selector cuando esté)
  (projectile-completion-system 'default)
  :config
  (projectile-mode)

  ;; No explotar con paths remotos (tramp, ssh, etc.)
  (defun muere/projectile-project-root-wrapper (f &rest args)
    "Wrapper sobre F (projectile-project-root), pasando ARGS."
    (unless (file-remote-p default-directory)
      (apply f args)))
  (advice-add 'projectile-project-root :around 'muere/projectile-project-root-wrapper)

  ;; Limpiar el keymap de projectile — no queremos sus bindings globales
  (setf (cdr projectile-mode-map) nil))

(provide 'muere-projectile)
;;; muere-projectile.el ends here
