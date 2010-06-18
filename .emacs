;; Need more comments! :P

(setq backup-directory-alist (quote ((".*" . "~/.emacs.d/backups"))))

(add-to-list 'load-path "~/elisp/")
(add-to-list 'load-path "~/elisp/color-theme-6.6.0")
(menu-bar-mode 0)
(require 'zenburn)
(zenburn)
;; (set-background-color "black")
;; (set-foreground-color "white")

(global-font-lock-mode t)
(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "K&R")
  (global-set-key "\C-u" 'c-electric-delete)
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 4))

(setq kill-whole-line t) 
(setq c-hungry-delete-key t)
;; (setq c-auto-newline 0)
(add-hook 'c-mode-common-hook
          '(lambda ()
             (turn-on-auto-fill)
             (setq fill-column 80)
             (setq comment-column 60)
             (modify-syntax-entry ?_ "w")       ; now '_' is not considered a word-delimiter
             (c-set-style "ellemtel")           ; set indentation style
             (local-set-key [(control tab)]     ; move to next tempo mark
                            'tempo-forward-mark)
             ))
(global-set-key "\C-o" 'dabbrev-expand)
(global-set-key "`" 'other-window)
(global-set-key "\M-g" 'goto-line)

(transient-mark-mode)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(debug-on-error t)
 '(display-battery-mode t)
 '(display-time-mode t)
 '(inhibit-startup-screen t)
 '(show-paren-mode t)
 '(speedbar-frame-parameters (quote ((minibuffer) (width . 20) (border-width . 0) (menu-bar-lines . 0) (tool-bar-lines . 0) (unsplittable . t) (set-background-color "black"))))
 '(transient-mark-mode t))
(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . linux-c-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . linux-c-mode))
(add-to-list 'auto-mode-alist '("\\.m\\'" . octave-mode))
(autoload 'javascript-mode "javascript" nil t)

(global-set-key "\C-u" 'delete-backward-char)

(add-hook 'octave-mode-hook
	  (lambda()
	    (setq octave-auto-indent 1)
	    (setq octave-blink-matching-block 1)
	    (setq octave-block-offset 8)
	    (setq octave-send-line-auto-forward 0)
	    (abbrev-mode 1)
	    (auto-fill-mode 1)
	    (if (eq window-system 'x)
		(font-lock-mode 1))))
;(load-file "~/elisp/emacs-for-python/epy-init.el")

;(setq tags-directory "~/.emacs.d/tags/")
;(setq tags-table-list      '("~/emacs.d/tag/"))

  (add-to-list 'load-path "~/elisp/emacs-codepad") ;; replace PATH with the path to codepad.el
  (autoload 'codepad-paste-region "codepad" "Paste region to codepad.org." t)
  (autoload 'codepad-paste-buffer "codepad" "Paste buffer to codepad.org." t)
  (autoload 'codepad-fetch-code "codepad" "Fetch code from codepad.org." t)

(setq backup-directory-alist
          `((".*" . ,temporary-file-directory)))
    (setq auto-save-file-name-transforms
          `((".*" ,temporary-file-directory t)))

;; Calendar.
;; {{{
(setq view-diary-entries-initially t
      mark-diary-entries-in-calendar t
      number-of-diary-entries 7)
(add-hook 'diary-display-hook 'fancy-diary-display)
(add-hook 'today-visible-calendar-hook 'calendar-mark-today)

(add-hook 'fancy-diary-display-mode-hook
	  '(lambda ()
	     (alt-clean-equal-signs)))

(defun alt-clean-equal-signs ()
  "This function makes lines of = signs invisible."
  (goto-char (point-min))
  (let ((state buffer-read-only))
    (when state (setq buffer-read-only nil))
    (while (not (eobp))
      (search-forward-regexp "^=+$" nil 'move)
      (add-text-properties (match-beginning 0) 
			   (match-end 0) 
			   '(invisible t)))
    (when state (setq buffer-read-only t))))

(define-derived-mode fancy-diary-display-mode  fundamental-mode
  "Diary"
  "Major mode used while displaying diary entries using Fancy Display."
  (set (make-local-variable 'font-lock-defaults)
       '(fancy-diary-font-lock-keywords t))
  (define-key (current-local-map) "q" 'quit-window)
  (define-key (current-local-map) "h" 'calendar))

(defadvice fancy-diary-display (after set-mode activate)
  "Set the mode of the buffer *Fancy Diary Entries* to
 fancy-diary-display-mode'."
  (save-excursion
    (set-buffer fancy-diary-buffer)
    (fancy-diary-display-mode)))

(require 'generic)
(define-generic-mode 'fancy-diary-display-mode
  nil
  (list "Exception" "Location" "Desc")
  '(
    ("\\(.*\\)\n\\(=+\\)"            ;; Day title / separator lines
     (1 'font-lock-keyword-face) (2 'font-lock-preprocessor-face))
    ("^\\(todo [^:]*:\\)\\(.*\\)$"   ;; To do entries
     (1 'font-lock-string-face) (2 'font-lock-reference-face))
    ("\\(\\[.*\\]\\)"                ;; Category labels
     1 'font-lock-constant-face)
    ("^\\(0?\\([1-9][0-9]?:[0-9][0-9]\\)\\([ap]m\\)?\\(-0?\\([1-9][0-9]?:[0-9][0-9]\\)\\([ap]m\\)?\\)?\\)"
     1 'font-lock-type-face))        ;; Time intervals at start of lines.
  nil
  (list
   (function
    (lambda ()
      (turn-on-font-lock))))
  "Mode for fancy diary display.")

(defun diary-schedule (m1 d1 y1 m2 d2 y2 dayname)
  "Entry applies if date is between dates on DAYNAME.  
    Order of the parameters is M1, D1, Y1, M2, D2, Y2 if
    european-calendar-style' is nil, and D1, M1, Y1, D2, M2, Y2 if
    european-calendar-style' is t. Entry does not apply on a history."
  (let ((date1 (calendar-absolute-from-gregorian
		(if european-calendar-style
		    (list d1 m1 y1)
		  (list m1 d1 y1))))
	(date2 (calendar-absolute-from-gregorian
		(if european-calendar-style
		    (list d2 m2 y2)
		  (list m2 d2 y2))))
	(d (calendar-absolute-from-gregorian date)))
    (if (and 
	 (<= date1 d) 
	 (<= d date2)
	 (= (calendar-day-of-week date) dayname)
	 (not (check-calendar-holidays date))
	 )
	entry)))

;; Countdown!

(defun diary-countdown (m1 d1 y1 n)
  "Reminder during the previous n days to the date.
    Order of parameters is M1, D1, Y1, N if
    european-calendar-style' is nil, and D1, M1, Y1, N otherwise."
  (diary-remind '(diary-date m1 d1 y1) (let (value) (dotimes (number n value) (setq value (cons number value))))))

;; }}}

;; {{{ Gnus
;; Todo!
;; }}}

