(require 'bind-key)
(require 'dash)

(bind-keys*
 ("M-<left>" . mb/start-of-line)
 ("M-<right>" . mb/end-of-line)
 ("M-<up>" . er/expand-region)
 ("M-<down>" . er/contract-region)
 ("A-<left>" . backward-word)
 ("A-<right>" . forward-word)
 ("A-<backspace>" . mb/backward-delete-word)
 ("A-S-<backspace>" . mb/delete-word)
 ("M-<backspace>" . mb/delete-whole-line)
 ("<escape>" . keyboard-escape-quit)
 ("M-<return>" . mb/open-line)
 ("M-S-<return>" . mb/open-line-above)
 ("M-d" . mb/duplicate-line-or-region)
 ("M-c" . mb/copy-line-or-region)
 ("M-v" . yank)
 ("M-r" . anzu-query-replace-regexp)
 ("M-f" . isearch-forward)
 ("M-F" . isearch-backward)
 ("M-x" . mb/cut-line-or-region)
 ("M-i" . mb/toolbox)
 ("M-z" . undo-only)
 ("M-Z" . undo)
 ("M-A" . smex)
 ("M-a" . mark-whole-buffer)
 ("M-J" . mb/join-line)
 ("C-p" . scroll-down-line)
 ("C-n" . scroll-up-line)
 ("C-f" . dired)
 ("M-j" . other-window)
 ("A-w" . split-window-right-and-move-there)
 ("A-W" . split-window-below-and-move-there)
 ("M-P" . projectile-switch-project)
 ("M-w" . delete-window)
 ("M--" . delete-other-windows)
 ("M-e" . ido-switch-buffer)
 ("M-E" . ido-switch-buffer-other-window)
 ("M-m" . imenu)
 ("M-s" . save-buffer)
 ("M-l" . goto-line-with-feedback)
 ("M-q" . save-buffers-kill-emacs)
 ("M-o" . projectile-find-file)
 ("M-O" . ido-find-file)

 ("<f1>" . magit-status)
 ("<f3>" . flycheck-list-errors)
 ("<f5>" . projectile-regenerate-tags)
 ("<f8>" . magit-blame))

(bind-keys :map isearch-mode-map
           ("M-f" . isearch-repeat-forward)
           ("M-." . etags-select-find-tag)
           ("M-F" . isearch-repeat-backward))

;;; esc ALWAYS quits

(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)


;; toolbox

(defvar *mb/tools* '(("log" . magit-file-log)
                     ("butler" . butler)
                     ("buffers" . ibuffer)
                     ("branch" . magit-checkout)
                     ("clean" . clean-up-buffer-or-region)
                     ("align" . align-regexp)
                     ("ack" . ack)
                     ("ag" . ag-project)
                     ("agl" . ag)
                     ("agf" . ag-project-files)
                     ("gist-list" . yagist-list)
                     ("gist" . yagist-region-or-buffer)
                     ("gistp" . yagist-region-or-buffer-private)
                     ("erc" . start-erc)
                     ("sh" . shell)
                     ("esh" . eshell)
                     ("mx" . smex)
                     ("sql" . sql-postgres)
                     ("gh" . open-github-from-here)
                     ("p" . prodigy)
                     ("mongo" . inf-mongo)
                     ("sql" . sql-postgres)
                     ("delete" . delete-this-buffer-and-file)
                     ("rename" . rename-this-file-and-buffer)
                     ("occur" . occur)
                     ("rubo" . rubocop-autocorrect-current-file)
                     ("emacs" . dired-to-emacs-dir)))

(defun mb/toolbox ()
  (interactive)
  (let ((choice (ido-completing-read "Tool: " (-map 'car *mb/tools*))))
    (--> choice
         (assoc-string it *mb/tools*)
         (cdr it)
         (funcall it))))

;; utils

(defun mb/line-beginning-text-position ()
  (save-excursion
    (beginning-of-line)
    (skip-chars-forward " \t")
    (point)))

(defun mb/end-of-previous-word ()
  (save-excursion
    (forward-word -1)
    (forward-word)
    (point)))

(defun mb/placeholder (msg)
  (message msg))

;; commands

(defun mb/duplicate-line-or-region ()
  (interactive)
  (save-excursion
    (if (region-active-p)
        (let ((deactivate-mark)
              (start (region-beginning))
              (end (region-end)))
          (goto-char end)
          (insert (buffer-substring start end)))
      (let ((line (buffer-substring (point-at-bol)
                                    (point-at-eol))))
        (end-of-line)
        (newline)
        (insert line)))))


(defun mb/join-line ()
  "join the current and next lines, with one space in between them"
  (interactive)
  (save-excursion
    (forward-line 1)
    (beginning-of-line)
    (delete-char -1)
    (just-one-space)))

(defun mb/backward-delete-word ()
  "delete by word"
  (interactive)
  (let ((start (point))
        (end-of-previous-word (mb/end-of-previous-word)))
    (if (eq start end-of-previous-word)
        (progn
          (forward-word -1)
          (delete-region start (point)))
      (delete-region end-of-previous-word start))))

(defun mb/delete-word ()
  (interactive)
  (let ((start (point)))
    (forward-word 1)
    (delete-region start (point))))

(defun mb/end-of-line ()
  (interactive "^")
  (end-of-line))

(defun mb/start-of-line ()
  (interactive "^")

  (if (eq (mb/line-beginning-text-position) (point))
      (beginning-of-line)
    (beginning-of-line-text)))

(defun mb/open-line ()
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defun mb/open-line-above ()
  (interactive)
  (beginning-of-line)
  (newline-and-indent)
  (forward-line -1)
  (indent-for-tab-command))

(defun mb/delete-whole-line ()
  (interactive)
  (delete-region (line-beginning-position)
                 (line-end-position))
  (delete-char -1)
  (forward-line 1)
  (beginning-of-line))

(defun mb/copy-line-or-region ()
  (interactive)
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
    (kill-ring-save (line-beginning-position) (line-end-position))))

(defun mb/cut-line-or-region ()
  (interactive)
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (kill-whole-line)))

(provide 'keybinds)
