;;; config.el -*- lexical-binding: t; -*-

(setq doom-theme 'doom-one
      display-line-numbers-type 'relative
      shell-file-name (executable-find "bash"))

;; Keep text opaque while making the background 70% opaque.
(setf (alist-get 'alpha-background default-frame-alist) 70)
(dolist (frame (frame-list))
  (when (display-graphic-p frame)
    (set-frame-parameter frame 'alpha-background 70)))

(add-to-list 'load-path (expand-file-name "~/.local/share/doom-vterm") t)

;; The user Home Manager generation is available before a full NixOS rebuild.
;; Expose its tools to GUI Emacs and all language servers.
(let ((bin (expand-file-name "~/.local/state/nix/profiles/home-manager/home-path/bin")))
  (when (file-directory-p bin)
    (add-to-list 'exec-path bin)
    (setenv "PATH" (concat bin path-separator (getenv "PATH")))))

;; Keep Fish in interactive terminal buffers, while Emacs runs subprocesses
;; through the POSIX shell above.
(after! vterm
  (setq vterm-shell (or (getenv "SHELL") "/run/current-system/sw/bin/fish")))

(after! plantuml-mode
  (when-let* ((plantuml (executable-find "plantuml"))
              (jar (expand-file-name "../lib/plantuml.jar"
                                     (file-name-directory (file-truename plantuml)))))
    (setq plantuml-default-exec-mode 'executable
          plantuml-jar-path jar)))

;; Home Manager links the Typst grammar to this XDG data directory.
(add-to-list 'treesit-extra-load-path
             (expand-file-name "doom-typst-grammar"
                               (or (getenv "XDG_DATA_HOME")
                                   (expand-file-name "~/.local/share"))))

(use-package! typst-ts-mode
  :mode ("\\.typ\\'" . typst-ts-mode)
  :hook (typst-ts-mode . eglot-ensure))

(after! eglot
  ;; Eglot reads workspace settings from the project root, so a buffer-local
  ;; setting in typst-ts-mode-hook would not reach Tinymist.
  (setq-default eglot-workspace-configuration
                (lambda (server)
                  (when (memq 'typst-ts-mode (eglot--major-modes server))
                    '(:exportPdf "onSave"
                      :outputPath "$root/$dir/$name"))))
  ;; Emacs' built-in Nix choices omit nil, the server installed by NixOS.
  (add-to-list 'eglot-server-programs '(nix-mode . ("nil")))
  (add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist")))
  (let ((jar (expand-file-name "~/.local/share/doom-java-debug/plugin.jar")))
    (when (file-exists-p jar)
      (add-to-list 'eglot-server-programs
                   `((java-mode java-ts-mode) .
                     ("jdtls" :initializationOptions (:bundles [,jar])))))))

;; Doom's Java module currently attaches LSP only for lsp-mode.
(add-hook 'java-mode-local-vars-hook #'lsp! 'append)

(defun andrey/open-pdf-in-zathura (pdf)
  "Open PDF in Zathura."
  (let ((zathura (or (executable-find "zathura")
                     (user-error "Zathura is not available"))))
    (start-process "zathura-pdf" nil zathura (expand-file-name pdf))))

(defun andrey/find-file-with-zathura (original filename &rest args)
  "Send local PDF files opened with ORIGINAL to Zathura."
  (if (and (stringp filename)
           (string-match-p "\\.pdf\\'" (downcase filename))
           (not (file-remote-p filename))
           (file-regular-p filename))
      (progn
        (andrey/open-pdf-in-zathura filename)
        (current-buffer))
    (apply original filename args)))

;; This also covers Treemacs and Dired, which open files through find-file.
(dolist (command '(find-file find-file-other-window find-file-other-frame))
  (advice-add command :around #'andrey/find-file-with-zathura))

(defun andrey/typst-view-pdf ()
  "Open the PDF for the current Typst file in Zathura."
  (interactive)
  (unless (and buffer-file-name (derived-mode-p 'typst-ts-mode))
    (user-error "Open a Typst file first"))
  (let ((pdf (concat (file-name-sans-extension buffer-file-name) ".pdf")))
    (unless (file-exists-p pdf)
      (user-error "No PDF yet: save the Typst file first"))
    (andrey/open-pdf-in-zathura pdf)))

(after! typst-ts-mode
  (map! :map typst-ts-mode-map
        :localleader
        :desc "View PDF in Zathura" "v" #'andrey/typst-view-pdf))
