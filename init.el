;;; init.el --- Where all the magic begins
;;
;; Part of the Emacs Starter Kit
;;
;; This is the first thing to get loaded.
;;
;; "Emacs outshines all other editing software in approximately the
;; same way that the noonday sun does the stars. It is not just bigger
;; and brighter; it simply makes everything else vanish."
;; -Neal Stephenson, "In the Beginning was the Command Line"

;; Turn off mouse interface early in startup to avoid momentary display
;; You really don't need these; trust me.
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Load path etc.

(setq dotfiles-dir (file-name-directory
                    (or (buffer-file-name) load-file-name)))

;; Load up ELPA, the package manager

(add-to-list 'load-path dotfiles-dir)

(add-to-list 'load-path (concat dotfiles-dir "/elpa-to-submit"))

(setq autoload-file (concat dotfiles-dir "loaddefs.el"))
(setq package-user-dir (concat dotfiles-dir "elpa"))
(setq custom-file (concat dotfiles-dir "custom.el"))

(require 'package)
(package-initialize)
(require 'starter-kit-elpa)

;; These should be loaded on startup rather than autoloaded on demand
;; since they are likely to be used in every session

(require 'cl)
(require 'saveplace)
(require 'ffap)
(require 'uniquify)
(require 'ansi-color)
(require 'recentf)

;; backport some functionality to Emacs 22 if needed
(require 'dominating-file)

;; Load up starter kit customizations

(require 'starter-kit-defuns)
(require 'starter-kit-bindings)
(require 'starter-kit-misc)
(require 'starter-kit-registers)
(require 'starter-kit-eshell)
(require 'starter-kit-lisp)
(require 'starter-kit-perl)
(require 'starter-kit-ruby)
(require 'starter-kit-js)

(regen-autoloads)
(load custom-file 'noerror)

;; You can keep system- or user-specific customizations here
(setq system-specific-config (concat dotfiles-dir system-name ".el")
      user-specific-config (concat dotfiles-dir user-login-name ".el")
      user-specific-dir (concat dotfiles-dir user-login-name))
(add-to-list 'load-path user-specific-dir)

(if (file-exists-p system-specific-config) (load system-specific-config))
(if (file-exists-p user-specific-config) (load user-specific-config))
(if (file-exists-p user-specific-dir)
    (mapc #'load (directory-files user-specific-dir nil ".*el$")))

;;; init.el ends here

;;; color themes
(add-to-list 'load-path "~/.emacs.d/color-theme-6.6.0")
(require 'color-theme)
(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-deep-blue)))

;;; add folding for ruby code
(add-hook 'ruby-mode-hook
              '(lambda ()
                 (outline-minor-mode)
                 (setq outline-regexp " *\\(def \\|class\\|module\\)")
                 (hide-body)))

;;; yasnippet
    (add-to-list 'load-path
                  "~/.emacs.d/vendor/yasnippet-0.6.1c")
    (require 'yasnippet) ;; not yasnippet-bundle
    (yas/initialize)
    (yas/load-directory "~/.emacs.d/vendor/yasnippet-0.6.1c/snippets")

;;; autotest & unit test integration
(load-file "~/.emacs.d/vendor/autotest.el")
(load-file "~/.emacs.d/vendor/unit-test.el")
(setq autotest-use-ui t)

;;; rcov
(load-file "~/.emacs.d/vendor/rcov.el")
;;; org-mode

(setq org-log-done 'time) ;; log when tasks are marked done

;;; mobile org config

;; Set to the location of your Org files on your local system
(setq org-directory "~/work/org-files")
;; Set to the name of the file where new notes will be stored
(setq org-mobile-inbox-for-pull "~/org/inbox.org")
;; Set to <your Dropbox root directory>/MobileOrg.
(setq org-mobile-directory "~/Dropbox/MobileOrg")

;;; rhtml-mode
(add-to-list 'load-path "~/.emacs.d/vendor/rhtml")
(require 'rhtml-mode)
(add-hook 'rhtml-mode-hook
  	  '(Lambda () (rinari-launch)))
(setq auto-mode-alist (cons '("\\.html.erb" . rhtml-mode) auto-mode-alist))

;; magit
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/")
(require 'magit-blame)
(global-set-key (kbd "C-c b") 'magit-blame-mode)

;; put an end to trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq show-trailing-whitespace t)

(setq org-agenda-files (list "~/tasks/sfweb.org"))
(setq org-agenda-files (list "~/org/agendas.org" "~/work/myforex/TODO.org"))

;;; erlang config
(setq load-path (cons  "/opt/local/lib/erlang/lib/tools-2.6.5.1/emacs" load-path))
(setq erlang-root-dir "/opt/local/lib/erlang")
(setq exec-path (cons "/opt/local/lib/erlang/bin" exec-path))
;;(require 'erlang-start)


;;; clojure config
(defun lein-swank ()
  (interactive)
  (let ((root (locate-dominating-file default-directory "project.clj")))
    (when (not root)
      (error "Not in a Leiningen project."))
    ;; you can customize slime-port using .dir-locals.el
    (shell-command (format "source $HOME/.bashrc && cd %s && lein swank %s &" root slime-port)
                   "*lein-swank*")
    (set-process-filter (get-buffer-process "*lein-swank*")
                        (lambda (process output)
                          (when (string-match "Connection opened on" output)
                            (slime-connect "localhost" slime-port)
                            (set-process-filter process nil))))
    (message "Starting swank server...")))

;; midje mode

(add-to-list 'load-path "~/.emacs.d/midje-mode")
(require 'clojure-mode)
(add-to-list 'auto-mode-alist '("\\.clj$" . clojure-mode))
(require 'midje-mode)
(add-hook 'clojure-mode-hook 'midje-mode)

;; slime with utf-8
(set-language-environment "UTF-8")
(setq slime-net-coding-system 'utf-8-unix) 

;; magit
(setq load-path (cons "/usr/local/share/emacs/site-lisp/" load-path))
(require 'magit-blame)
(global-set-key (kbd "C-c b") 'magit-blame-mode)

;; php mode
(require 'php-mode)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))

;; nrepl
(add-to-list 'load-path "~/repos/nrepl.el")
(require 'nrepl)


;; haskell-mode
(load "~/repos/haskell-mode/haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)
(setq haskell-program-name "/usr/local/bin/ghci")
