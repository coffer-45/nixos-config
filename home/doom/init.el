;;; init.el -*- lexical-binding: t; -*-

(doom! :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       dashboard
       hl-todo
       modeline
       (popup +defaults)
       treemacs
       (vc-gutter +pretty)
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       snippets
       (whitespace +guess +trim)

       :emacs
       dired
       electric
       tramp
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       debugger
       (docker +lsp)
       editorconfig
       (eval +overlay)
       lookup
       (lsp +eglot)
       magit
       make

       :lang
       (cc +lsp)
       data
       emacs-lisp
       (java +lsp)
       (markdown +lsp)
       (nix +lsp)
       plantuml
       (python +lsp)
       (rust +lsp)
       sh
       (yaml +lsp)

       :config
       (default +bindings +smartparens))
