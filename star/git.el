;; -*- lexical-binding: t -*-

(luna-def-key
 :leader
 "g"  '("git")
 "gs" #'magit-status
 "gf" '("file")
 "gfc" #'magit-file-checkout
 "gfl" #'magit-log-buffer-file)

(load-package magit
  :commands magit-status
  :config
  (define-key magit-mode-map (kbd "<tab>") 'magit-section-toggle)

  ;; recenter
  (add-hook 'magit-status-mode-hook
            (lambda () (add-hook 'post-command-hook #'recenter 70 t)))

  ;; Disable electric-quote-mode in commit message buffer.
  (add-hook 'text-mode-hook
            (lambda ()
              (when (equal (buffer-name) "COMMIT_EDITMSG")
                (electric-quote-mode -1))))

  ;; Patch
  (defun magit-patch-apply-buffer (buffer &rest args)
    "Apply the patch buffer BUFFER."
    (interactive
     (list (read-buffer "Apply patch in buffer: " nil t)
           (transient-args 'magit-patch-apply)))
    (with-temp-buffer
      (insert-buffer-substring-no-properties buffer)
      (magit-run-git-with-input "apply" args "-")
      (magit-refresh)))
  (require 'magit-patch)
  (transient-append-suffix 'magit-patch-apply "a"
    '("b" "Apply patch in buffer" magit-patch-apply-buffer)))

(load-package magit-patch-changelog
  :after magit)

(load-package magit-todos
  :hook (magit-mode . magit-todos-mode))

(load-package git-link
  :commands git-link)
