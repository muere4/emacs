;;; muere-selector --- selection and winnowing -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(require 'muere-package)

(use-package selector
  :load-path "~/.emacs.d/lisp"
  :custom
  (completing-read-function #'selector-completing-read)
  (read-file-name-function  #'selector-read-file-name)
  :config
  (global-set-key (kbd "M-x") 'selector-M-x)
  (evil-define-key 'normal selector-minibuffer-map
    (kbd "q") 'selector-quit)

  (defun muere/selector-active-buffers ()
    (selector-source-create
     "IRC (Active)"
     :candidates
     (--map (selector-candidate-create it :face 'muere/notify)
            (cl-remove-if-not #'muere/buffer-active-p
                              (muere/buffer-list)))
     :actions selector-buffer-actions))

  (defun muere/selector-irc-buffers ()
    (selector-source-create
     "IRC"
     :candidates
     (cl-remove-if-not #'muere/buffer-irc-p (muere/buffer-list))
     :actions selector-buffer-actions))

  (defun muere/selector-eshell-buffers ()
    (selector-source-create
     "Shells"
     :candidates
     (mapcar
      (lambda (buf)
        (selector-candidate-create
         (concat "In "
                 (muere/replace-home (muere/buffer-directory buf))
                 " (named " buf ")")
         :value buf))
      (cl-remove-if-not #'muere/buffer-eshell-p (muere/buffer-list)))
     :actions selector-buffer-actions))

  (defun muere/selector-surface-buffers ()
    "Selector source para Wayland surface buffers (EWM)."
    (selector-source-create
     "Wayland Apps"
     :candidates
     (cl-remove-if-not #'muere/buffer-exwm-p (muere/buffer-list))
     :actions selector-buffer-actions))

  (defun muere/selector-unaffiliated-buffers ()
    (selector-source-create
     "Buffers"
     :candidates
     (muere/unaffiliated-buffers)
     :actions selector-buffer-actions))

  (defun muere/selector-project-buffers ()
    (selector-source-create
     "Project Buffers"
     :candidates
     (when (projectile-project-p)
       (cl-remove-if #'muere/buffer-boring-p
                     (projectile-project-buffer-names)))
     :actions selector-buffer-actions))

  (defun muere/selector-project-files ()
    (selector-source-create
     "Project Files"
     :candidates
     (when (projectile-project-p)
       (cl-loop
        with root = (projectile-project-root)
        for display in (projectile-current-project-files)
        collect (selector-candidate-create
                 display
                 :value (expand-file-name display root))))
     :actions selector-file-actions))

  (defun muere/selector-create-file-or-buffer ()
    (selector-source-create
     "Other"
     :candidates
     (list
      (selector-candidate-create
       "Create buffer"
       :type 'dummy
       :action (lambda (_) (switch-to-buffer (selector-input))))
      (selector-candidate-create
       "Create file"
       :type 'dummy
       :action (lambda (_) (find-file (selector-input)))))))

  (defun muere/navigate ()
    (interactive)
    (selector
     (list
      (muere/selector-active-buffers)
      (muere/selector-project-buffers)
      (muere/selector-surface-buffers)
      (muere/selector-unaffiliated-buffers)
      (muere/selector-eshell-buffers)
      (muere/selector-project-files)
      (muere/selector-bookmarks)
      (selector-recentf-source)
      (muere/selector-search)
      (muere/selector-create-file-or-buffer))))

  (defvar muere/external-commands-list nil)

  (defun muere/run-external-command ()
    (interactive)
    (setq muere/external-commands-list
          (cl-loop
           for dir in (split-string (getenv "PATH") path-separator)
           when (and (file-exists-p dir)
                     (file-accessible-directory-p dir))
           for lsdir = (cl-loop
                        for i in (directory-files dir t)
                        for bn = (file-name-nondirectory i)
                        when (and (not (member bn completions))
                                  (not (file-directory-p i))
                                  (file-executable-p i))
                        collect bn)
           append lsdir into completions
           finally return (sort completions 'string-lessp)))
    (selector
     (list (selector-source-create
            "Commands"
            :candidates muere/external-commands-list
            :actions
            (list (lambda (cmd)
                    (start-process cmd nil cmd)))))
     :initial "^"))

  (defun muere/selector-rg ()
    "Sources para líneas encontradas via ripgrep."
    (interactive)
    (let ((query (read-string "rg: ")))
      (defun conv (x)
        (cons (car x)
              (cons (- (string-to-number (cadr x)) 1)
                    (caddr x))))
      (defun all-in-file (key list)
        (--map (to-candidate (cdr it))
               (--filter (s-equals? key (car it)) list)))
      (defun to-candidate (x)
        (selector-candidate-create (cdr x) :value (car x)))
      (let* ((result
              (with-temp-buffer
                (call-process "rg" nil t nil "-n" query ".")
                (buffer-string)))
             (lines
              (--map (conv (s-split-up-to ":" it 2))
                     (--filter (not (s-blank? it))
                               (s-split "\n" result))))
             (files (-uniq (-map #'car lines)))
             (sources
              (--map
               (selector-source-create
                it
                :candidates (all-in-file it lines)
                :actions (selector-file-contents-actions it))
               files)))
        (when sources
          (selector sources))))))

(provide 'muere-selector)
;;; muere-selector.el ends here
