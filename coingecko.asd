(defpackage coingecko/system
  (:use :common-lisp
        :asdf)
  (:export :author
           :copyright
           :version-string
           :version-list
           :version-major
           :version-minor
           :version-revision))
(in-package :coingecko/system)

(defparameter author "Christopher Mark Gore <cgore@cgore.com>")
(defparameter copyright "Copyright © 2023 Christopher Mark Gore, all rights reserved.")
(defparameter version-major    0)
(defparameter version-minor    0)
(defparameter version-revision 1)

(defun version-list ()
  (list version-major version-minor version-revision))

(defun version-string ()
  (format nil "~{~A.~A.~A~}" (version-list)))

(defsystem "coingecko"
  :description "Library for interfacing with CoinGecko's API"
  :version #.(version-string)
  :author author
  :license "BSD 3-Clause"
  :depends-on ("alexandria" "dexador" "function-cache" "quri" "sigma" "yason")
  :components ((:module "source" :components ((:file "main"     :depends-on ("rest-api"))
                                              (:file "rest-api")))))
