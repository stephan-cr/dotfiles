;;; init.el

;; Author: Stephan Creutz

; functions
(defun on-host (hostname)
  "get the current hostname on which this instance is running"
  (string-equal (car (split-string system-name "\\.")) hostname))

(defun terminal-type ()
  "get the current terminal name"
  (getenv "TERM"))

(require 'json)
(defvar user-config-filename "~/.emacs.d/user-config.json")
(defvar user-config nil)
(when (file-exists-p user-config-filename)
  (setq user-config (let ((json-object-type 'hash-table))
                      (json-read-file user-config-filename))))

; indention style and end of line whitespace handling
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)

; show an empty scratch buffer
(setq initial-scratch-message nil)
; remove splash screen
(setq inhibit-startup-message t)

; case sensitiv search
(setq-default case-fold-search nil)

; http://www.thekidder.com/2008/10/21/emacs-reload-file/
(defun reload-file ()
  (interactive)
  (let ((curr-scroll (window-vscroll)))
    (find-file (buffer-name))
    (set-window-vscroll nil curr-scroll)
    (message "Reloaded file")))

(global-set-key (kbd "<XF86Reload>") 'reload-file)

(global-set-key [f12] 'comment-region)
(global-set-key [shift-f12] 'uncomment-region)

; smooth scrolling
(setq scroll-conservatively 1)

; automatically remove end of line white space
;(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'before-save-hook 'whitespace-cleanup)

; show column numbers
(column-number-mode)

; no menu bar
(menu-bar-mode -1)

; distinguish buffers of the same filename
; http://tsengf.blogspot.com/2011/06/distinguish-buffers-of-same-filename-in.html
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

; set browser to Chromium instead of Iceweasel which is the default
(require 'browse-url)
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "chromium-browser")

; things to do when in X mode
(when (eq window-system 'x)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (set-face-attribute 'default nil :height 80)
  (global-hl-line-mode t))
(when (or (eq window-system 'mac) (eq window-system 'ns))
  (tool-bar-mode -1)
  (global-hl-line-mode t)
  (set-face-background 'hl-line "gray95")
  (set-face-attribute 'default nil :height 120))

; enable flyspell minor mode automatically for Latex (AuCTeX)
(require 'flyspell)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(setq flyspell-use-meta-tab nil)

; bibtex mode settings
(eval-when-compile (require 'bibtex))
(setq bibtex-align-at-equal-sign t)

; windmove
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings)
  (setq windmove-wrap-around t))

; ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer)

; use aspell instead of ispell
(setq ispell-program-name "aspell")

; conf mode for Mercurial hgrc files
(add-to-list 'auto-mode-alist '("\\hgrc?\\'" . conf-mode))

; shell mode for zsh files (as in oh-my-zsh)
(add-to-list 'auto-mode-alist '("\\.zsh?\\'" . sh-mode))

; markdown-mode for "md|markdown" files
(add-to-list 'auto-mode-alist '("\\.\\(md\\|markdown\\)\\'" . markdown-mode))

; extend load path
(setq load-path (cons "~/.emacs.d/" load-path))

; duplicate current line or region in emacs
; http://blog.tuxicity.se/elisp/emacs/2010/03/11/duplicate-current-line-or-region-in-emacs.html
(defun duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times.
If there's no region, the current line will be duplicated. However, if
there's a region, all lines that region covers will be duplicated."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

(global-set-key (kbd "C-c d") 'duplicate-current-line-or-region)

(defun kill-forward-whitespace ()
  "Kill the whitespace from the current position until the next
non-whitespace character"
  (interactive)
  (let ((start-point (point))
        (end (skip-chars-forward " \t\n\r")))
    (kill-region start-point (+ end start-point))))

(global-set-key (kbd "C-c w") 'kill-forward-whitespace)

; highlight current line
(eval-and-compile (require 'cl)) ; for reduce
(defun is-suitable-color-term ()
  (let ((suitable-color-term-list '("rxvt" "xterm-256color"))
        (current-term-name (getenv "TERM")))
    (if current-term-name
        (reduce
         #'(lambda (a b) (or a (not (null (string-match b current-term-name)))))
         suitable-color-term-list
         :initial-value nil))) nil)

(when (is-suitable-color-term)
  (global-hl-line-mode t)
  (set-face-background 'hl-line "gray20"))

; navigating in the kill-ring
; http://emacs-fu.blogspot.com/2010/04/navigating-kill-ring.html
(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings))

; org mode
(require 'org)
(defvar agenda-files (list "~/orgs/todo.org"))
(when (and (featurep 'org) (or (on-host "earth3") (on-host "earth7")))
  (when agenda-files
    (setq org-agenda-files agenda-files))
  (global-set-key "\C-ca" 'org-agenda)
  (global-set-key "\C-cb" 'org-iswitchb)
  (global-set-key "\C-cl" 'org-store-link)
  (setq org-default-notes-file (concat (getenv "HOME") "/orgs/notes.org"))
  (setq org-capture-templates
        '(("t" "Note" entry (file+headline "~/orgs/notes.org" "Notes")
           "* TODO %?\n  %i\n  %a")))
  (define-key global-map "\C-cc" 'org-capture)
  (global-set-key [f5] 'org-display-inline-images))

; define "scrartcl" KOMA document class for org mode latex export
; we know that the initial first element of `org-export-latex-classes' is
; "article", we use it to define "scrartcl" in a convenient way
(when (require 'org-latex nil t)
  (add-to-list 'org-export-latex-classes
               (concatenate 'list
                            '("scrartcl" "\\documentclass[11pt]{scrartcl}")
                            (cddr (car org-export-latex-classes)))))

; org babel mode
(when (and (featurep 'org) (featurep 'ob))
  (mapc 'require '(ob-C
                   ob-R
                   ob-dot
                   ob-emacs-lisp
                   ob-gnuplot
                   ob-perl
                   ob-python
                   ob-ruby
                   ob-sh))
  ;; set python coding to utf-8
  (setq org-babel-python-wrapper-method
        (concat "# -*- coding: utf-8 -*-\n"
                org-babel-python-wrapper-method))
  (when (>= emacs-major-version 24) (setq org-src-fontify-natively t)))

; erc
(when (require 'erc nil t)
  (eval-when-compile (require 'erc))
  (setq erc-server "se07")
  (setq erc-port 6667))

; jabber
(defvar jabber-resource-name
  (when user-config (gethash "jabber-resource-name" user-config)))

(when jabber-resource-name
  (require 'jabber)
  (setq jabber-account-list
        (add-to-list 'jabber-account-list jabber-resource-name))
  (eval-when-compile (require 'jabber-roster))
  (setq jabber-roster-show-title nil)
  (setq jabber-roster-show-bindings nil)
  (setq jabber-show-offline-contacts nil)
  ;; turn off fsm debug buffer used by jabber mode
  (eval-when-compile (require 'fsm))
  (setq fsm-debug nil))

; emms
(when (require 'emms nil t)
  (require 'emms-setup)
  (require 'emms-player-mpd)
  (eval-when-compile (require 'emms-player-simple))
  (require 'emms-streams)
  (setq emms-player-mpg321-parameters '("-o" "alsa"))
  (emms-standard)
  (emms-default-players)

  ;; for debugging
  ;; (emms-player-for
  ;;  '(*track*
  ;;    (type . url)
  ;;    (name . "http://streamer-dtc-aa04.somafm.com:80/stream/1073")))

  ;; for help to configure emms see
  ;; http://www.mail-archive.com/emms-help@gnu.org/msg00482.html

  ;; emms player to play urls
  (define-emms-simple-player mpg321-list '(file url)
    (regexp-opt '(".m3u" ".pls")) "mpg321" "-o" "alsa" "--list")
  (define-emms-simple-player mpg321-url '(url)
    "http://" "mpg321" "-o" "alsa")
  (define-emms-simple-player mpg321-file '(file)
    (regexp-opt '(".mp3")) "mpg321" "-o" "alsa")
  (setq emms-player-list '(emms-player-mpg321-file
                           emms-player-mpg321-url
                           emms-player-mpg321-list
                           emms-player-mpd)))

; use multimedia keys
(when (eq window-system 'x)
  (global-set-key (kbd "<XF86AudioLowerVolume>") 'emms-volume-lower)
  (global-set-key (kbd "<XF86AudioRaiseVolume>") 'emms-volume-raise)
  (global-set-key (kbd "<XF86AudioPrev>") 'emms-previous)
  (global-set-key (kbd "<XF86AudioNext>") 'emms-next)
  (global-set-key (kbd "<XF86AudioPlay>") 'emms-start)
  (global-set-key (kbd "<XF86AudioStop>") 'emms-stop))

(defun do-initial-window-split ()
  "do a initial split of windows"
  (interactive)
  (split-window-horizontally)
  (next-multiframe-window)
  (split-window-vertically)
  (split-window-vertically)
  (split-window-horizontally)
  (previous-multiframe-window))

(global-set-key [f9] 'do-initial-window-split)

; http://stringofbits.net/2009/08/emacs-23-dbus-and-libnotify/
; with slight modifications by me
(when (require 'dbus nil t)
  (eval-when-compile (require 'dbus))
  (defvar emacs-icon-path (concat "/usr/share/emacs/"
                                  (number-to-string emacs-major-version)
                                  "."
                                  (number-to-string emacs-minor-version)
                                  "/etc/images/icons/hicolor/24x24/apps/"
                                  "emacs.png"))
  (defun send-desktop-notification (summary body timeout-ms)
    "call notification-daemon method METHOD with ARGS over dbus"
    (dbus-call-method
     :session                         ; use the session (not system) bus
     "org.freedesktop.Notifications"  ; service name
     "/org/freedesktop/Notifications" ; path name
     "org.freedesktop.Notifications"  ; interface
     "Notify"                         ; method
     "emacs"
     0
     emacs-icon-path ; path to pixmap
     summary
     body
     '(:array)
     '(:array :signature "{sv}")
     ':int32 timeout-ms))

  (when (and (featurep 'dbus) (not (eq system-type 'darwin))
             (not (null (dbus-list-names :session))))
    (send-desktop-notification "terminal type" (terminal-type) 3000))

  ;; notification when title changed
  (add-hook 'emms-player-started-hook
            #'(lambda () (send-desktop-notification "EMMS" (emms-show) 3000))))

; gnus
; http://mah.everybody.org/docs/mail/
; set default backend
(eval-when-compile (require 'gnus))
(when user-config
  (setq gnus-select-method '(nnimap
                             "SE"
                             (nnimap-address
                              (gethash "mail-host-address" user-config))
                             (nnimap-stream tls))))
(eval-when-compile (require 'gnus-sum))
(setq gnus-summary-thread-gathering-function
      'gnus-gather-threads-by-subject)
; http://www.emacswiki.org/emacs/GnusFormatting
(setq-default
 gnus-summary-line-format "%U%R%z %(%&user-date;  %-15,15f %* %B%s%)\n"
 gnus-user-date-format-alist '((t . "%d.%m.%Y %H:%M"))
 gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references
 gnus-thread-sort-functions '(gnus-thread-sort-by-date)
 gnus-sum-thread-tree-false-root ""
 gnus-sum-thread-tree-indent " "
 gnus-sum-thread-tree-leaf-with-other "├► "
 gnus-sum-thread-tree-root ""
 gnus-sum-thread-tree-single-leaf "╰► "
 gnus-sum-thread-tree-vertical "│"
 )

; send mail via msmtp
(eval-when-compile (require 'sendmail))
(setq sendmail-program "/usr/bin/msmtp")
(eval-when-compile (require 'message))
(setq message-send-mail-function 'message-send-mail-with-sendmail)
(setq message-sendmail-extra-arguments '("-a" "se"))
(when user-config
  (setq mail-host-address (gethash "mail-host-address" user-config))
  (setq user-full-name (gethash "user-full-name" user-config))
  (setq user-mail-address (gethash "user-mail-address" user-config)))

; gnus window setup
(eval-when-compile (require 'gnus-win))
(setq gnus-use-full-window nil)

; kill message buffer after it was successfully send
(setq message-kill-buffer-on-exit t)

; tramp setup
(require 'tramp)

; themes
(defvar theme-tag 'solarized-theme)

(case theme-tag
  ('default-theme
    (set-face-background 'hl-line "gray95"))
  ('solarized-theme
   ;; (setq load-path (cons "~/external_projects/emacs-color-theme-solarized"
   ;;                       load-path))
   ;; (require 'color-theme-solarized)
   ;; (setq solarized-termcolors 256)
   ;; (color-theme-solarized-light)
   (setq custom-theme-directory "~/.emacs.d/themes")
   (load-theme 'solarized-light)
   (set-face-background 'hl-line "gray95")
   )
  ('naquadah-theme
   ;; naquadah theme
   (defvar naquadah-path "~/naquadah-theme")
   (when (and naquadah-path
              (>= (string-to-number (substring (current-time-string) 11 13)) 12))
     (load-file (concat naquadah-path "/naquadah-theme.el")))))

; override `message-expand-name' from message.el to lookup aliases from mutt
; when composing messages
(when (or (on-host "earth3") (on-host "earth7"))
  (require 'message)
  (eval-and-compile (require 'mutt-alias))
  (require 'thingatpt)
  ;; mutt alias lookup
  (setq mutt-alias-file-list '("~/.mutt/muttrc"))
  (defun message-expand-name ()
    (cond ((and (memq 'eudc message-expand-name-databases)
                (boundp 'eudc-protocol)
                eudc-protocol)
           (eudc-expand-inline))
          ((and (memq 'bbdb message-expand-name-databases)
                (fboundp 'bbdb-complete-name))
           (bbdb-complete-name))
          ((and (memq 'mutt-alias message-expand-name-databases)
                (featurep 'mutt-alias))
           (let ((expansion (mutt-alias-expand (word-at-point))))
             (when expansion
               (beginning-of-thing 'word)
               (kill-word 1)
               (insert expansion))))
          (t
           (expand-abbrev))))
  (setq message-expand-name-databases '(mutt-alias))
  ;; (add-to-list 'message-expand-name-databases 'mutt-alias)
)

; bookmark setting
;; automatically save bookmarks
(eval-when-compile (require 'bookmark))
(setq bookmark-save-flag 1)

; open man page in the current buffer
(eval-when-compile (require 'man))
(setq Man-notify-method 'pushy)

(defun untabify-buffer ()
  "untabifies the whole buffer"
  (interactive)
  (untabify (point-min) (point-max)))

(defun insert-code-author ()
  "Inserts the code author and its email address into the source code. The
inserted line is automatically put in comments.

The function assumes that the user set the variables `user-full-name' and
`user-mail-address'."
  (interactive)
  (let* ((peek-string (lambda (str n)
                        (if (< n 0)
                            (elt str (- (length str) (abs n)))
                          (elt str n))))
         (insert-space? (lambda (str n)
                          (if (and (> (length str) 0)
                                   (/= (funcall peek-string str n) ?\s))
                              " " ""))))
    (insert (concat comment-start (funcall insert-space? comment-start -1)
                    "Author: " user-full-name " <" user-mail-address ">"
                    comment-end (funcall insert-space? comment-end 0) "\n"))))

(global-set-key [f11] 'insert-code-author)

; auto completion
;; (when (on-host "xyz")
;;   (require 'auto-complete)
;;   (require 'auto-complete-clang)
;;   (setq clang-completion-suppress-error t)

;;   (defun my-c-mode-common-hook ()
;;     (eval-when-compile (require 'auto-complete))
;;     (setq ac-auto-start nil)
;;     (setq ac-expand-on-auto-complete nil)
;;     (setq ac-quick-help-delay 0.3)
;;     (eval-when-compile (require 'cc-mode))
;;     (define-key c-mode-base-map (kbd "M-/") 'ac-complete-clang))

;;   (add-hook 'c-mode-common-hook 'my-c-mode-common-hook))

; start emacs server
(require 'server)
(unless (server-running-p server-name)
  (server-start))

; http://irreal.org/blog/?p=297
(defun eval-and-replace (value)
  "Evaluate the sexp at point and replace it with its value"
  (interactive (list (eval-last-sexp nil)))
  (kill-sexp -1)
  (insert (format "%S" value)))

(require 'python)
(define-key python-mode-map (kbd "RET") 'newline-and-indent)
(add-hook 'python-mode-hook 'turn-on-eldoc-mode) ; check if that really works

; compilation
(setq compilation-auto-jump-to-first-error t)
(setq compilation-scroll-output 'first-error)

; shows the function name we are in most programming modes
(which-func-mode 1)

; don't place customizations directly into init.el
(setq custom-file "~/.emacs.d/custom.el")