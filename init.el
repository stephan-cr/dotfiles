;;; init.el

;; Author: Stephan Creutz

;; functions

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(when (< emacs-major-version 27)
  (package-initialize))

;; fix https issues
;; https://emacs.stackexchange.com/questions/51721/failed-to-download-gnu-archive
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(defun on-host (hostname)
  "Get the current HOSTNAME on which this instance is running."
  (string-equal (car (split-string (system-name) "\\.")) hostname))

;; reduce the frequency of garbage collection
(setq gc-cons-threshold (* 4 1024 1024))

;; increase the amount of data which Emacs reads from the process
(setq read-process-output-max (* 1024 1024))

;; no menu bar
(menu-bar-mode -1)

;; things to do when in X mode
(when (eq window-system 'x)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (if (member "Roboto Mono" (font-family-list))
      (set-face-attribute 'default nil :font "Roboto Mono 8")
    (set-face-attribute 'default nil :height 80))
  (global-hl-line-mode t))
(when (or (eq window-system 'mac) (eq window-system 'ns))
  (tool-bar-mode -1)
  (global-hl-line-mode t)
  (set-face-background 'hl-line "gray95")
  (set-face-attribute 'default nil :height 120))

(require 'cl-generic)
(require 'cl-macs)

(cl-defgeneric configuration-lookup (self sym))

;; load configuration
(cl-defstruct (plist-configuration
               (:constructor plist-configuration-create)
               (:copier nil)) ()
              plist)
(cl-defmethod configuration-lookup ((self plist-configuration)
                                    (sym symbol))
  (plist-get (plist-configuration-plist self) sym))

(let ((filename (concat user-emacs-directory "user-config.elconf"))
      config-plist)
  (setq config-plist
        (with-temp-buffer
          (insert-file-contents filename)
          (read (current-buffer))))
  (setq user-config (plist-configuration-create :plist config-plist)))

;; indention style and end of line whitespace handling
(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default show-trailing-whitespace t)
(setq-default indicate-empty-lines t)

(setq frame-title-format
      (list '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

;; show an empty scratch buffer
(setq initial-scratch-message nil)
;; remove splash screen
(setq inhibit-startup-message t)

;; case sensitiv search
(setq-default case-fold-search nil)

;; show matching parenthesis
(show-paren-mode 1)
(setq show-paren-delay 0.8)

;; don't blink
(blink-cursor-mode -1)

;; set initial major mode for *scratch* buffer
(setq initial-major-mode 'python-mode)

;; http://www.thekidder.com/2008/10/21/emacs-reload-file/
(defun reload-file ()
  (interactive)
  (let ((curr-scroll (window-vscroll)))
    (find-file (buffer-name))
    (set-window-vscroll nil curr-scroll)
    (message "Reloaded file")))

(global-set-key (kbd "<XF86Reload>") #'reload-file)

(global-set-key [f7] #'vc-resolve-conflicts)
(global-set-key [f8] #'find-file-at-point)
(global-set-key [f12] #'comment-region)
(global-set-key [shift-f12] #'uncomment-region)

;; smooth scrolling
(setq scroll-conservatively 1)

;; automatically remove end of line white space
(add-hook 'before-save-hook #'delete-trailing-whitespace)
;; (add-hook 'before-save-hook 'whitespace-cleanup)

;; show column numbers
(column-number-mode t)

(size-indication-mode 1)

;; paste at point, instead of mouse position
(setq mouse-yank-at-point t)

;; distinguish buffers of the same filename
;; http://tsengf.blogspot.com/2011/06/distinguish-buffers-of-same-filename-in.html
;; http://pragmaticemacs.com/emacs/uniquify-your-buffer-names/
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(setq uniquify-after-kill-buffer-p t)
(setq uniquify-ignore-buffers-re "^\\*")

;; set browser to Firefox
(require 'browse-url)
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox")

;; enable flyspell minor mode automatically for Latex (AuCTeX)
(eval-after-load 'flyspell
  '(progn
     (add-hook 'LaTeX-mode-hook #'flyspell-mode)
     (setq flyspell-use-meta-tab nil)))

;; bibtex mode settings
(eval-when-compile (require 'bibtex))
(setq bibtex-align-at-equal-sign t)

;; windmove
(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings)
  (setq windmove-wrap-around t))

;; ibuffer
(global-set-key (kbd "C-x C-b") #'ibuffer)

;; ido mode
(require 'ido)
(ido-mode t)
(setq ido-case-fold nil)
(define-key ido-file-completion-map "\C-k" nil)

;; use aspell instead of ispell
(setq ispell-program-name "aspell")

;; conf mode for Mercurial hgrc files
(add-to-list 'auto-mode-alist '("\\hgrc?\\'" . conf-mode))

;; shell mode for zsh files (as in oh-my-zsh)
(add-to-list 'auto-mode-alist '("\\.zsh?\\'" . sh-mode))

;; markdown-mode for "md|markdown" files
(add-to-list 'auto-mode-alist '("\\.\\(md\\|markdown\\)\\'" . markdown-mode))

;; duplicate current line or region in emacs
;; http://blog.tuxicity.se/elisp/emacs/2010/03/11/duplicate-current-line-or-region-in-emacs.html
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

(global-set-key (kbd "C-c d") #'duplicate-current-line-or-region)

(defun kill-forward-whitespace ()
  "Kill the whitespace from the current position until the next
non-whitespace character"
  (interactive)
  (let ((start-point (point))
        (end (skip-chars-forward " \t\n\r")))
    (kill-region start-point (+ end start-point))))

(global-set-key (kbd "C-c w") #'kill-forward-whitespace)

;; highlight current line
(defun is-suitable-color-term ()
  (let ((suitable-color-term-list '("rxvt" "xterm-256color"))
        (current-term-name (getenv "TERM")))
    (consp (member current-term-name suitable-color-term-list))))

(when (is-suitable-color-term)
  (global-hl-line-mode t)
  (set-face-background 'hl-line "gray20"))

;; org mode
(setq org-enforce-todo-checkbox-dependencies t
      org-enforce-todo-dependencies t)

(eval-after-load 'org
  '(progn
     (define-key org-mode-map (kbd "RET") #'org-return-indent)

     (defvar agenda-files (list "~/orgs/todo.org"))
     (when (or (on-host "earth3") (on-host "earth4") (on-host "earth7"))
       (when agenda-files
         (setq org-agenda-files agenda-files))
       (global-set-key "\C-ca" #'org-agenda)
       (global-set-key "\C-cb" #'org-iswitchb)
       (global-set-key "\C-cl" #'org-store-link)
       (setq org-directory "~/orgs/"
             org-default-notes-file (concat org-directory "notes.org")
             org-capture-templates
             '(("t" "Note" entry (file+headline org-default-notes-file "Notes")
                "* TODO %?\n  %i\n  %a")))
       (define-key global-map "\C-cc" #'org-capture)
       (global-set-key [f5] #'org-display-inline-images)
       (setq org-mobile-directory "~/mobileorg"
             org-mobile-inbox-for-pull (concat org-directory "from-mobile.org")
             org-mobile-files '("todo.org")))

     ;; define "scrartcl" KOMA document class for org mode latex
     ;; export we know that the initial first element of
     ;; `org-latex-classes' is "article", we use it to define
     ;; "scrartcl" in a convenient way
     (when (require 'ox-latex nil 'noerror)
       (add-to-list 'org-latex-classes
                    (append '("scrartcl" "\\documentclass[11pt]{scrartcl}")
                            (cddr (car org-latex-classes)))))

     ;; org babel mode
     (when (featurep 'ob)
       (mapc #'require `(ob-C
                         ob-R
                         ob-dot
                         ob-emacs-lisp
                         ob-gnuplot
                         ob-lisp
                         ob-plantuml
                         ob-python
                         ob-scheme
                         ,(if (>= emacs-major-version 26) 'ob-shell 'ob-sh)))
       ;; set python coding to utf-8
       (setq org-babel-python-wrapper-method
             (concat "# -*- coding: utf-8 -*-\n"
                     org-babel-python-wrapper-method))
       (when (>= emacs-major-version 24) (setq org-src-fontify-natively t)))

     ;; http://sachachua.com/blog/2012/12/emacs-strike-through-headlines-for-done-tasks-in-org/
     (setq org-fontify-done-headline t)
     (set-face-attribute 'org-done nil :strike-through t)
     (set-face-attribute 'org-headline-done nil :strike-through t)

     ;; encryption and decryption of org entries with the tag :encrypt:
     (require 'org-crypt)
     (org-crypt-use-before-save-magic)
     (setq org-tags-exclude-from-inheritance (quote ("encrypt"))
           org-crypt-key nil)))

;; erc
(when (require 'erc nil 'noerror)
  (eval-when-compile (require 'erc))
  (setq erc-server "irc.freenode.net")
  (setq erc-port 6667))

;; emms
(eval-after-load 'emms
  '(progn
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
                              emms-player-mpd))))

;; use multimedia keys
(when (eq window-system 'x)
  (global-set-key (kbd "<XF86AudioLowerVolume>") #'emms-volume-lower)
  (global-set-key (kbd "<XF86AudioRaiseVolume>") #'emms-volume-raise)
  (global-set-key (kbd "<XF86AudioPrev>") #'emms-previous)
  (global-set-key (kbd "<XF86AudioNext>") #'emms-next)
  (global-set-key (kbd "<XF86AudioPlay>") #'emms-start)
  (global-set-key (kbd "<XF86AudioStop>") #'emms-stop))

(defun do-initial-window-split ()
  "Do a initial split of windows."
  (interactive)
  (split-window-horizontally)
  (next-multiframe-window)
  (split-window-vertically)
  (split-window-vertically)
  (split-window-horizontally)
  (previous-multiframe-window))

(global-set-key [f9] #'do-initial-window-split)

;; http://stringofbits.net/2009/08/emacs-23-dbus-and-libnotify/
;; with slight modifications by me
(when (and (require 'dbus nil 'noerror) (eq window-system 'x))
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

  ;; notification when title changed
  (add-hook 'emms-player-started-hook
            #'(lambda () (send-desktop-notification "EMMS" (emms-show) 3000))))

;; gnus
;; http://mah.everybody.org/docs/mail/
;; set default backend
(eval-after-load 'gnus
  '(progn
     (when user-config
       (setq gnus-select-method `(nnimap
                                  "default"
                                  (nnimap-address
                                   ,(configuration-lookup user-config
                                                          :imap-host-address))
                                  (nnimap-server-port "imaps")
                                  (nnimap-stream tls))))
     (eval-when-compile (require 'gnus-sum))
     (setq gnus-summary-thread-gathering-function
           'gnus-gather-threads-by-subject)
     ;; http://www.emacswiki.org/emacs/GnusFormatting
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
      gnus-sum-thread-tree-vertical "│")
     ;; reduce verbose messages
     (setq gnus-novice-user nil
           gnus-inhibit-startup-message t)
     ;; gnus window setup
     (eval-when-compile (require 'gnus-win))
     (setq gnus-use-full-window nil)))

(when (eq window-system 'x)
  (global-set-key (kbd "<XF86Mail>") #'gnus))

;; send mail via msmtp
(eval-when-compile (require 'sendmail))
(setq sendmail-program "/usr/bin/msmtp")

(eval-after-load 'message
  '(progn
     (setq message-send-mail-function 'message-send-mail-with-sendmail
           message-sendmail-extra-arguments
           `("-a" ,(configuration-lookup user-config :mail-msmtp-account)))

     ;; kill message buffer after it was successfully send
     (setq message-kill-buffer-on-exit t)))

(when user-config
  (setq mail-host-address (configuration-lookup user-config :mail-host-address)
        user-full-name (configuration-lookup user-config :user-full-name)
        user-mail-address (configuration-lookup user-config :user-mail-address)))

;; override `message-expand-name' from message.el to lookup aliases from mutt
;; when composing messages
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
  (setq message-expand-name-databases '(mutt-alias)))

;;; bookmark setting
;; automatically save bookmarks
(eval-when-compile (require 'bookmark))
(setq bookmark-save-flag 1)

;; open man page in the current buffer
(eval-when-compile (require 'man))
(setq Man-notify-method 'pushy)

(defun untabify-buffer ()
  "Untabifies the whole buffer."
  (interactive)
  (save-excursion
    (untabify (point-min) (point-max))))

(defun insert-code-author ()
  "Insert the code author and its email address into buffer.
The inserted line is automatically put in comments.

The function assumes that the user set the variables
`user-full-name' and `user-mail-address'."
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

(global-set-key [f11] #'insert-code-author)

;; start emacs server
(require 'server)
(unless (server-running-p server-name)
  (server-start))

;; http://irreal.org/blog/?p=297
(defun eval-and-replace (value)
  "Evaluate the sexp at point and replace it with its value."
  (interactive (list (eval-last-sexp nil)))
  (kill-sexp -1)
  (insert (format "%S" value)))

;; eldoc
(require 'eldoc)
(setq eldoc-idle-delay 0)

(require 'ielm)
(add-hook 'ielm-mode-hook #'turn-on-eldoc-mode)

(add-hook 'emacs-lisp-mode-hook #'turn-on-eldoc-mode)

(require 'python)
(add-hook 'python-mode-hook #'subword-mode)
(add-hook 'python-mode-hook #'turn-on-eldoc-mode)

(setq python-shell-interpreter "python3")
(when (= emacs-major-version 25)
  (add-to-list 'python-shell-completion-native-disabled-interpreters
                                        ; doesn't exist before Emacs
                                        ; 25 and workaround is not
                                        ; required after 25
               "python3")) ; workaround

(when (require 'ess nil 'noerror)
  (setq ess-ask-for-ess-directory nil
        inferior-R-args "--no-save --quiet")
  ;; disable ess-smart-underscore
  (substitute-key-definition 'ess-smart-underscore 'self-insert-command
                             ess-mode-map)

  (if (require 'ess-eldoc nil 'noerror)
      (add-hook 'inferior-ess-mode-hook #'ess-use-eldoc)
    (setq ess-use-eldoc t)))

;; compilation
(setq compilation-auto-jump-to-first-error t
      compilation-scroll-output 'first-error)

;; flymake for python with pylint
;; http://www.emacswiki.org/emacs/?action=browse;id=PythonProgrammingInEmacs
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))
  (defun flymake-mode-wrapper ()
    ;; check if buffer-file-name is nil, such we can use flymake in combination
    ;; with org-babel
    (when buffer-file-name (flymake-mode)))

  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init))
  (add-hook 'python-mode-hook #'flymake-mode-wrapper))

;; shows the function name we are in most programming modes
(which-function-mode 1)

;; don't place customizations directly into init.el
(setq custom-file (concat user-emacs-directory "custom.el"))

;; newline and indent for all prog modes, but don't interfere with
;; electric-mode
(unless (featurep 'electric)
  (define-key prog-mode-map (kbd "RET") #'newline-and-indent))

;; sql-mode settings
(eval-after-load 'sql
  '(progn (message "Setting sql-product to postgres")
          (setq sql-product 'postgres)
          (add-to-list 'sql-postgres-options "--no-psqlrc")
          (message "Setting sqlite program to \"sqlite3\"")
          (setq sql-sqlite-program "sqlite3")))

;; Save point position between sessions
;; http://whattheemacsd.com/init.el-03.html
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (expand-file-name "places" user-emacs-directory))
(when (>= emacs-major-version 25)
  (save-place-mode t))

;; transparent encryption and decryption
;; the default file extension is *.gpg
(require 'epa-file)
(epa-file-enable)
(setq epa-file-select-keys nil)

;; http://emacsredux.com/blog/2013/05/04/rename-file-and-buffer/
(defun rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (set-visited-file-name new-name t t)))))))

(add-to-list 'load-path (concat user-emacs-directory "el-get/el-get"))

(when (< emacs-major-version 24)
  ;; fake variable which is introduced in Emacs 24
  (defvar custom-theme-load-path nil))

;;; el-get setup
(setq el-get-github-default-url-type 'https) ; for some reason http does not work anymore (as of 07-01-2014)
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(add-to-list 'el-get-recipe-path "~/dotfiles/el-get-user-recipes")
(defvar el-get-packages (append
                         '(bnf-mode
                           browse-kill-ring
                           cmake-mode
                           company-mode
                           diff-hl
                           dockerfile-mode
                           doom-modeline
                           doom-themes
                           el-get
                           elfeed
                           eval-sexp-fu
                           flycheck
                           geiser
                           ghub
                           glsl-mode
                           go-mode
                           groovy-emacs-mode ; for Jenkins pipelines
                           helm
                           helm-swoop
                           indicators
                           js2-mode
                           json-mode
                           lsp-mode
                           lsp-ui
                           lua-mode
                           magit
                           markdown-mode
                           meson-mode
                           modern-cpp-font-lock
                           monky
                           org-present
                           paredit
                           pretty-lambdada
                           project-explorer
                           projectile
                           rainbow-delimiters
                           rst-mode
                           rust-mode
                           slime
                           toml-mode
                           volatile-highlights
                           which-key
                           yaml-mode
                           yasnippet
                           yasnippet-snippets)
                         (mapcar 'el-get-source-name el-get-sources)))
(el-get-cleanup el-get-packages)
(el-get 'sync el-get-packages)

;; navigating in the kill-ring
;; http://emacs-fu.blogspot.com/2010/04/navigating-kill-ring.html
(when (require 'browse-kill-ring) ;; browse-kill-ring seems to be gone
  (browse-kill-ring-default-keybindings))

;; themes
(defvar theme-tag (if (>= emacs-major-version 24)
                      'doom-acario-light-theme 'default-theme))

(defun stc:load-theme (theme)
  "Load THEME with proper function."
  (if (>= emacs-major-version 24) (load-theme theme t) (load-theme theme)))

(cl-case theme-tag
  ('default-theme
    (set-face-background 'hl-line "gray95"))
  ('doom-opera-theme
   (stc:load-theme 'doom-opera)
   (doom-modeline-mode 1))
  ('doom-acario-light-theme
   (stc:load-theme 'doom-acario-light)
   (doom-modeline-mode 1))
  ('deeper-blue-theme
   (stc:load-theme 'deeper-blue)))

;; go path, such that go-mode finds godef
(let ((home (getenv "HOME")))
  (dolist (path '("/gocode/bin" "/go/bin"))
    (let ((full-path (concat home path)))
      (when (and (file-directory-p full-path) (not (member full-path exec-path)))
        (add-to-list 'exec-path full-path)))))

;; bash lint - http://skybert.net/emacs/bash-linting-in-emacs/
(add-hook 'sh-mode-hook #'flycheck-mode)

(defun define-prettify-symbols ()
  (setq prettify-symbols-alist
        '(("lambda" . ?λ)
          ("->" . ?→)
          ("<=" . ?≤)
          (">=" . ?≥)
          ("and" . ?∧)
          ("or" . ?∨)
          ("'()" . ?∅)
          ("sqrt" . ?√)
          ("inf" . ?∞))))

;; http://seclists.org/oss-sec/2017/q3/422
(eval-after-load "enriched"
  '(defun enriched-decode-display-prop (start end &optional param)
     (list start end)))

;; http://joy.pm/post/2017-09-17-a_graphviz_primer/
(defun fix-inline-images ()
  "Redisplay all inline images automatically."
  (when org-inline-image-overlays
    (org-redisplay-inline-images)))

(add-hook 'org-babel-after-execute-hook #'fix-inline-images)

(with-eval-after-load 'org-present
  (add-hook 'org-present-mode-hook
            (lambda ()
              (org-present-big)
              (org-display-inline-images)
              (org-present-hide-cursor)
              (org-present-read-only)))
  (add-hook 'org-present-mode-quit-hook
            (lambda ()
              (org-present-small)
              (org-remove-inline-images)
              (org-present-show-cursor)
              (org-present-read-write))))

(when (>= emacs-major-version 25)
  (eval-after-load 'bytecomp
    '(add-to-list 'byte-compile-not-obsolete-funcs
                  #'preceding-sexp)))

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode-enable)

(require 'eval-sexp-fu)

;;; slime setup
(when (featurep 'slime)
  (require 'slime-highlight-edits)
  (require 'slime-quicklisp)
  (setq inferior-lisp-program "/usr/bin/sbcl"
        slime-contribs '(slime-banner
                         slime-fancy
                         slime-highlight-edits
                         slime-quicklisp))
  (add-hook 'slime-repl-mode-hook #'enable-paredit-mode)
  (add-hook 'slime-repl-mode-hook #'rainbow-delimiters-mode-enable)
  (dolist (mode '(turn-on-eval-sexp-fu-flash-mode
                  enable-paredit-mode
                  rainbow-delimiters-mode-enable
                  slime-highlight-edits-mode))
    (add-hook 'slime-mode-hook mode t)))

;;; geiser setup
(when (and (require 'geiser-chicken nil 'noerror) (featurep 'geiser))
  (add-to-list 'geiser-chicken-load-path
               (concat (getenv "HOME") "/lib/chicken/8")))

(when (featurep 'geiser)
  (setq geiser-active-implementations '(chez chicken guile mit)
        geiser-default-implementation 'guile
        geiser-repl-skip-version-check-p t)
  (dolist (mode '(enable-paredit-mode
                  define-prettify-symbols
                  turn-on-geiser-mode
                  turn-on-prettify-symbols-mode))
    (add-hook 'scheme-mode-hook mode t))
  (add-hook 'geiser-repl-mode-hook #'enable-paredit-mode)
  (add-hook 'geiser-repl-mode-hook #'rainbow-delimiters-mode-enable))

(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'emacs-lisp-mode-hook #'turn-on-eval-sexp-fu-flash-mode)
(add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook #'enable-paredit-mode)

(require 'modern-cpp-font-lock)
(add-hook 'c++-mode-hook #'modern-c++-font-lock-mode)

;;; projectile setup
(projectile-mode 1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;;; which-key setup
(which-key-mode 1)

(global-set-key (kbd "<XF86Favorites>") #'ielm)

(progn
  (prefer-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8))

;;; magit setup
(global-set-key (kbd "C-x g") #'magit-status)
(add-hook 'magit-pre-refresh-hook #'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh)

;;; monky setup
(require 'monky)
(setq monky-process-type 'cmdserver)

;;; volatile highlights setup
(volatile-highlights-mode 1)

;;; helm setup
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x C-b") #'helm-buffers-list)

(setq doom-modeline-python-executable "python3")

;;; lsp setup
(require 'lsp)
(require 'lsp-clangd)

(define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
;; according to https://github.com/emacs-lsp/lsp-mode/issues/1532 the
;; following is merely for which-key integration and doesn't define
;; any key map
(setq lsp-keymap-prefix "C-c l")
(setq lsp-enable-which-key-integration t)
(setq lsp-auto-guess-root t)

(add-hook 'rust-mode-hook #'lsp-deferred)

;; clangd setup
(let ((clangd-major 7))
  (setq lsp-clients-clangd-executable (format "clangd-%d" clangd-major)))

;;; diff-hl setup
(global-diff-hl-mode)
