;;; muere-utility --- miscellaneous utility functions -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)

(use-package cl-lib)
(use-package s)
(use-package dash)
(use-package f)

(defvar muere/boring-buffer-regexp-list
  '("\\` "
    "\\`\\*dhall"
    "\\`\\*poetry"
    "\\`\\*tramp"
    "\\`\\*Org PDF"
    "\\`\\*Org Preview"
    "\\`\\magit-process"
    "\\`\\*Echo Area"
    "\\`\\*Minibuf"
    "\\`\\*eldoc"
    "*direnv*"
    "*Pinentry*"
    "*Shell Command Output*"
    "*poetry*"))

(defvar-local muere/buffer-notify nil)

(defface muere/notify
  '((t :underline t
       :foreground "red"
       :weight bold))
  "Face para alertas en `muere/navigate'.")

(defvar muere/home (getenv "HOME"))

(defun muere/buffer-active-p (buf)
  "Check si BUF está activo."
  (buffer-local-value 'muere/buffer-notify (get-buffer buf)))

(defun muere/buffer-org-p (buf)
  "Check si BUF es un buffer `org-mode'."
  (member
   (buffer-local-value 'major-mode (get-buffer buf))
   '(org-mode)))

(defun muere/buffer-irc-p (buf)
  "Check si BUF es un buffer IRC de Circe."
  (member
   (buffer-local-value 'major-mode (get-buffer buf))
   '(circe-server-mode circe-channel-mode circe-query-mode)))

(defun muere/buffer-eshell-p (buf)
  "Check si BUF es un buffer EShell."
  (member
   (buffer-local-value 'major-mode (get-buffer buf))
   '(eshell-mode)))

(defun muere/buffer-exwm-p (buf)
  "Check si BUF es una surface EWM (Wayland)."
  (eq (buffer-local-value 'major-mode (get-buffer buf))
      'ewm-surface-mode))

(defun muere/minor-modes ()
  "Retornar todos los minor modes del buffer actual."
  (cl-remove-if
   (lambda (x) (not (and (symbolp x) (symbol-value x))))
   (mapcar 'car minor-mode-alist)))

(defun muere/buffer-directory (buf)
  "Retornar el `default-directory' de BUF."
  (buffer-local-value 'default-directory (get-buffer buf)))

(defun muere/buffer-boring-p (buffer)
  "Retornar non-nil si BUFFER es aburrido."
  (cl-reduce
   (lambda (x y) (or x y))
   (mapcar (lambda (r) (string-match r buffer))
           muere/boring-buffer-regexp-list)))

(defun muere/buffer-list ()
  "Retornar lista de buffers no aburridos."
  (cl-remove-if 'muere/buffer-boring-p
                (mapcar 'buffer-name (buffer-list))))

(defun muere/unaffiliated-buffers ()
  "Retornar lista de buffers sin afiliar."
  (cl-remove-if
   (lambda (b) (or (muere/buffer-irc-p b)
                   (muere/buffer-eshell-p b)
                   (muere/buffer-exwm-p b)))
   (muere/buffer-list)))

(defun muere/previous-buffer ()
  "Cambiar al buffer anterior."
  (interactive)
  (switch-to-buffer (cadr (muere/buffer-list))))

(defun muere/replace-home (dir)
  "Reemplazar home en DIR con tilde."
  (interactive)
  (if (file-remote-p dir) dir
    (s-replace muere/home "~" dir)))

(defun muere/dirname (path)
  "Retornar el directorio más interno de PATH."
  (file-name-nondirectory
   (directory-file-name (file-name-directory path))))

(defun muere/read-file (path)
  "Leer la primera s-expresión del archivo en PATH."
  (with-temp-buffer
    (insert-file-contents path)
    (read (current-buffer))))

(defun muere/nop ()
  "No hacer nada."
  (interactive)
  nil)

(defun muere/git-dirty (dir)
  "Retornar non-nil si el repo Git DIR tiene cambios sin commitear."
  (let ((out (process-lines "git" "-C" dir
                            "diff-index" "--quiet" "HEAD" "--")))
    (not (null out))))

(defun muere/screenshot ()
  "Tomar screenshot."
  (interactive)
  (start-process "grim" nil "grim"
                 (expand-file-name
                  (format "~/shots/screenshot-%s.png"
                          (format-time-string "%Y%m%d-%H%M%S")))))

(defun muere/snip ()
  "Copiar un área de la pantalla."
  (interactive)
  (start-process-shell-command
   "snip" nil
   "grim -g \"$(slurp)\" ~/shots/snip-$(date +%Y%m%d-%H%M%S).png"))

(defun muere/pop-mark ()
  "Pop del mark ring al mark actual del buffer."
  (when mark-ring
    (set-marker (mark-marker) (car mark-ring))
    (set-marker (car mark-ring) nil)
    (unless (mark t) (ding))
    (pop mark-ring))
  (deactivate-mark))

(defun muere/pop-to-mark-command ()
  "Saltar al mark y hacer pop del ring."
  (interactive)
  (if (null (mark t))
      (user-error "No mark set in this buffer")
    (if (= (point) (mark t))
        (message "Mark popped"))
    (goto-char (mark t))
    (muere/pop-mark)))

(defun muere/unpop-to-mark-command ()
  "Unpop del mark ring."
  (interactive)
  (when mark-ring
    (set-marker (mark-marker) (car (last mark-ring)) (current-buffer))
    (when (null (mark t)) (ding))
    (setq mark-ring (nbutlast mark-ring))
    (goto-char (marker-position (car (last mark-ring))))))

(defsubst muere/dir-file-name (file dir)
  (expand-file-name
   (substring file 0 (1- (length file))) dir))

(defsubst muere/dir-name-p (str)
  (char-equal (aref str (1- (length str))) ?/))

(cl-defun muere/walk-directory (directory &key (path 'basename)
                                          directories match noerror)
  "Recorrer árbol DIRECTORY.
PATH puede ser basename, relative, full, o una función.
DIRECTORIES cuando t incluye directorios.
MATCH es un regexp para filtrar.
NOERROR cuando t saltea directorios inaccesibles."
  (let ((fn (cl-case path
               (basename 'file-name-nondirectory)
               (relative 'file-relative-name)
               (full     'identity)
               (t        path))))
    (cl-labels ((ls-rec (dir)
                  (unless (file-symlink-p dir)
                    (cl-loop
                     for f in (sort (file-name-all-completions "" dir)
                                    'string-lessp)
                     unless (member f '("./" "../"))
                     if (and (muere/dir-name-p f)
                             (muere/dir-file-name f dir))
                     nconc
                     (unless (or (and noerror
                                      (not (file-accessible-directory-p it))))
                       (if (and directories
                                (or (null match) (string-match match f)))
                           (nconc (list (concat (funcall fn it) "/"))
                                  (ls-rec it))
                         (ls-rec it)))
                     else nconc
                     (when (and (null (eq directories 'only))
                                (or (null match) (string-match match f)))
                       (list (funcall fn (expand-file-name f dir))))))))
      (ls-rec directory))))

(use-package moon-phase :load-path "~/.emacs.d/lisp")

(provide 'muere-utility)
;;; muere-utility.el ends here
