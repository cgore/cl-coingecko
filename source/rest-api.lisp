(defpackage #:coingecko/rest-api
  (:use :common-lisp)
  (:export :ping))

(in-package :coingecko/rest-api)

(defvar *v3-public* "https://api.coingecko.com/api/v3")
(defvar *v3-pro*    "https://pro-api.coingecko.com/api/v3")
(defvar *v3*        *v3-public*)
(defvar *api*       *v3*)

(defun ping ()
  (dex:get (quri:make-uri :defaults (concatenate 'string *api* "/ping"))))
