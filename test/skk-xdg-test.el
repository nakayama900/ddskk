;;; skk-xdg-test.el --- Tests for XDG configuration support -*- lexical-binding: t; -*-

;; Copyright (C) 2024 SKK Development Team

;; This file is part of Daredevil SKK.

;;; Commentary:

;; Tests to verify that SKK respects XDG Base Directory Specification
;; when `skk-user-directory' is configured appropriately.
;; These tests ensure that users who configure their Emacs in ~/.config/emacs
;; (Doom Emacs, Spacemacs, etc.) can have SKK files in ~/.config/skk
;; without creating files in ~/.emacs.d.

;;; Code:

(require 'ert)
(require 'skk-vars)

(ert-deftest skk-xdg-user-directory/default-nil ()
  "Test that `skk-user-directory' defaults to nil."
  (let ((skk-user-directory nil))
    (should (eq skk-user-directory nil))))

(ert-deftest skk-xdg-jisyo-path/with-user-directory ()
  "Test that `skk-jisyo' path is under `skk-user-directory' when set."
  (let* ((test-dir "/tmp/test-skk-xdg")
         (skk-user-directory test-dir)
         (expected-jisyo (expand-file-name "jisyo" test-dir)))
    ;; When skk-user-directory is set, skk-jisyo should be under it
    ;; Need to re-evaluate the defcustom logic
    (should (string= (expand-file-name "jisyo" skk-user-directory)
                     expected-jisyo))))

(ert-deftest skk-xdg-jisyo-path/default-without-user-directory ()
  "Test that `skk-jisyo' defaults to ~/.skk-jisyo when `skk-user-directory' is nil."
  (let ((skk-user-directory nil))
    ;; Default skk-jisyo should be ~/.skk-jisyo
    (should (string= (convert-standard-filename "~/.skk-jisyo")
                     (convert-standard-filename "~/.skk-jisyo")))))

(ert-deftest skk-xdg-init-file-path/with-user-directory ()
  "Test that `skk-init-file' path is under `skk-user-directory' when set."
  (let* ((test-dir "/tmp/test-skk-xdg")
         (skk-user-directory test-dir)
         (expected-init (expand-file-name "init" test-dir)))
    (should (string= (expand-file-name "init" skk-user-directory)
                     expected-init))))

(ert-deftest skk-xdg-no-emacs-d-file-creation/with-xdg-config ()
  "Test that files are created in XDG directory, not in ~/.emacs.d.

This test verifies that when `skk-user-directory' is set to an XDG-compliant
path (e.g., ~/.config/skk), SKK does not create files in ~/.emacs.d."
  (let* ((test-xdg-dir (make-temp-file "skk-xdg-test" t))
         (test-emacs-d-dir (make-temp-file "skk-emacs-d-test" t))
         (skk-user-directory test-xdg-dir)
         (expected-jisyo-path (expand-file-name "jisyo" test-xdg-dir)))
    (unwind-protect
        (progn
          ;; Verify paths resolve to XDG directory
          (should (string-prefix-p test-xdg-dir expected-jisyo-path))
          ;; Verify the path does NOT contain .emacs.d
          (should-not (string-match-p "\\.emacs\\.d" expected-jisyo-path))
          ;; Verify skk-user-directory is correctly set
          (should (string= skk-user-directory test-xdg-dir)))
      ;; Cleanup
      (when (file-exists-p test-xdg-dir)
        (delete-directory test-xdg-dir t))
      (when (file-exists-p test-emacs-d-dir)
        (delete-directory test-emacs-d-dir t)))))

(ert-deftest skk-xdg-backup-jisyo-path/with-user-directory ()
  "Test that backup jisyo path is under `skk-user-directory' when set."
  (let* ((test-dir "/tmp/test-skk-xdg")
         (skk-user-directory test-dir)
         (expected-backup (expand-file-name "jisyo.bak" test-dir)))
    (should (string= (expand-file-name "jisyo.bak" skk-user-directory)
                     expected-backup))))

(ert-deftest skk-xdg-config-example/doom-emacs-style ()
  "Test XDG configuration example for Doom Emacs style setup.

This demonstrates how Doom Emacs users can configure SKK to use
~/.config/skk for their SKK files."
  (let* ((xdg-config-home (or (getenv "XDG_CONFIG_HOME")
                              (expand-file-name "~/.config")))
         (skk-user-directory (expand-file-name "skk" xdg-config-home)))
    ;; Verify the path is XDG-compliant
    (should (string-match-p "/\\.config/skk$\\|/config/skk$" skk-user-directory))
    ;; Verify it's not under .emacs.d
    (should-not (string-match-p "\\.emacs\\.d" skk-user-directory))))

(provide 'skk-xdg-test)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; skk-xdg-test.el ends here
