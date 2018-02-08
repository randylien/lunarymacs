;;;###autoload
(defun moon/sync-hlinum-face ()
  (interactive)
  (set-face-attribute
   'linum-highlight-face nil
   :background (face-attribute 'hl-line :background)
   :foreground (face-attribute 'font-lock-keyword-face :foreground)
   :weight 'bold
   ))

;;;###autoload
(defun moon/match-number-line-backgroud-color ()
  (interactive)
  (set-face-background 'linum (face-attribute 'default :background) nil)
  )