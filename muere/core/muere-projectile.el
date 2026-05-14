;;; muere-projectile --- project management -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)

(use-package projectile
  :custom
  (projectile-completion-system 'default)
  :config
  (projectile-mode)
  (defun muere/projectile-project-root-wrapper (f &rest args)
    "Wrapper de F (projectile-project-root), pasando ARGS."
    (unless (file-remote-p default-directory)
      (apply f args)))
  (advice-add 'projectile-project-root
              :around 'muere/projectile-project-root-wrapper)
  (setf (cdr projectile-mode-map) nil))

(provide 'muere-projectile)
;;; muere-projectile.el ends here
