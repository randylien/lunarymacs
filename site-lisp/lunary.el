;;; -*- lexical-binding: t -*-
;;
;; Variables, functions and macros that are needed for config files

;;; UI
(require 'lunary-ui)

;;; Package
;;;; Variable

(defvar luna-autoload-file (expand-file-name "autoload.el" user-emacs-directory)
  "The path of autoload file which has all the autoload functions.")

(defvar luna-star-enable-alist nil
  "((star1 . t) (star2 . nil)), then start1 is enabled and star2 is not.")

(defvar luna-cache-dir (expand-file-name "cache" user-emacs-directory)
  "The dir for cache files.")

(defvar luna-package-list nil
  "List of package symbols. Added by ‘load-package’.")

;;;; Functions

(defmacro luna-message-error (&rest body)
  "Eval BODY and print error message if any."
  `(condition-case err
       (progn ,@body)
     (error (message (format "Error occured:\n%s\n" (error-message-string err))))))

(defun luna-safe-load (file &rest args)
  "Load FILE and don’t error out.
ARGS is as same as in `load'."
  (luna-message-error
   (apply #'load file args)))

(defun luna-load-or-create (file &rest args)
  "Load FILE if file exists, otherwise create it.
ARGS is as same as in `load'."
  (if (file-exists-p file)
      (apply #'luna-safe-load file args)
    (save-excursion
      (find-file file)
      (save-buffer)
      (kill-buffer))))

(defun luna-load-relative (file &rest args)
  "Load FILE relative to user-emacs-directory. ARGS are applied to ‘load'."
  (apply #'luna-load-or-create (expand-file-name file user-emacs-directory) args))

(defmacro load-package (package &rest body)
  "Thin wrapper around ‘use-package’."
  (declare (indent 1))
  `(luna-message-error (add-to-list 'luna-package-list ',package t)
                       (use-package ,package
                         ,@body)))

(defvar luna-prepared-p nil
  "T if ‘luna-before-install-package’ has ran.")

(defun luna-before-install-package ()
  "Setup for installing packages."
  (interactive)
  (require 'cowboy)
  (require 'package)
  (package-initialize t)
  (package-refresh-contents)
  (setq luna-prepared-p t))

(defun luna-install-all-package ()
  "Install  packages."
  (interactive)
  (display-buffer "*Messages*")
  (unless luna-prepared-p
    (luna-before-install-package))
  (dolist (package luna-package-list)
    (cowboy-install package)))

(defmacro luna-lsp/eglot (lsp eglot)
  "Run LSP or EGLOT based on `luna-lsp'."
  `(pcase luna-lsp
     ('lsp ,lsp)
     ('eglot ,eglot)))

;;; Format on save

(defvar luna-smart-format-alist ()
  "Alist of format functions of each major mode.
Each element should be a con cell of major mode symbol and function symbol.
For example, '(python-mode . format-python)")

(defvar-local luna-format-on-save nil
  "Whether to format on save.")

(defun luna-smart-format-buffer ()
  "Only format buffer when `luna-format-on-save' is non-nil."
  (interactive)
  (when luna-format-on-save
    (let ((format-func (alist-get major-mode luna-smart-format-alist)))
      (when format-func
        (funcall format-func)))))

(add-hook 'after-save-hook #'luna-smart-format-buffer)

;;; buffer ordering

(defvar luna-buffer-bottom-list nil
  "Buffer name patterns that stays at the bottom of buffer list in helm.
Each pattern is the beginning of the buffer name, e.g., *Flymake, magit:, etc.")

(provide 'lunary)

