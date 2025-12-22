;;; im-cursor-chg.el --- Change cursor color for input method  -*- lexical-binding: t; -*-

;; Inspired by code from cursor-chg
;; URL: https://github.com/emacsmirror/cursor-chg/blob/master/cursor-chg.el
;; URL: https://github.com/Eason0210/im-cursor-chg
;; LICENSE: https://www.emacswiki.org/

;;; Commentary:
;;
;; To turn on the cursor color change by default,
;; put the following in your Emacs init file.
;;
;; (require 'im-cursor-chg)
;; (cursor-chg-mode 1)
;;
;;; Code:

(require 'rime nil t)

(defvar im-cursor-color "Orange"
  "The color for input method.")

(defvar im-default-cursor-color (frame-parameter nil 'cursor-color)
  "The default cursor color.")

(defun im--chinese-p ()
  "Check if the current input state is Chinese."
  (if (featurep 'rime)
      (and (rime--should-enable-p)
           (not (rime--should-inline-ascii-p))
           current-input-method)
    current-input-method))

(defun gui-cursor-color ()
  "GUI Emacs cursor color."
  (set-cursor-color (if (im--chinese-p)
                        im-cursor-color
                      im-default-cursor-color))
  )

(defun terminal-cursor-color ()
  "Terminal Emacs cursor color."
  (send-string-to-terminal (if (im--chinese-p)
                               (format "\e]12;%s\a" im-cursor-color)
                             (format "\e]12;%s\a" im-default-cursor-color)))
  )

(defun terminal-restore-cursor-color ()
  "Restore terminal cursor color."
  (unless (display-graphic-p)
    (send-string-to-terminal
     (format "\e]12;%s\a" im-default-cursor-color))))

(defun terminal-restore-before-exit (&rest _)
  "Exit terminal Emacs restore terminal color."
  (terminal-restore-cursor-color))

; exit emacs
(add-hook 'kill-emacs-hook #'terminal-restore-cursor-color t)
; suspend emacs
(add-hook 'suspend-hook #'terminal-restore-cursor-color t)
; daemon/client, exit emacsclient
(advice-add 'save-buffers-kill-terminal
            :before
            #'terminal-restore-before-exit)


(defun im-change-cursor-color ()
  "Set cursor color depending on input method."
  (interactive)
  (if (display-graphic-p)
      (gui-cursor-color)
    (terminal-cursor-color)))

(define-minor-mode cursor-chg-mode
  "Toggle changing cursor color.
With numeric ARG, turn cursor changing on if ARG is positive.
When this mode is on, `im-change-cursor-color' control cursor changing."
  :init-value nil :global t :group 'frames
  (if cursor-chg-mode
      (add-hook 'post-command-hook 'im-change-cursor-color)
    (remove-hook 'post-command-hook 'im-change-cursor-color)))


(provide 'im-cursor-chg)
;;; im-cursor-chg.el ends here
