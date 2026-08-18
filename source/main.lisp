;;;; Copyright (c) 2023 -- 2026, Christopher Mark Gore,
;;;; Soli Deo Gloria,
;;;; All rights reserved.
;;;;
;;;; 22 Forest Glade Court, Saint Charles, Missouri 63304 USA.
;;;; Web: http://cgore.com
;;;; Email: cgore@cgore.com
;;;;
;;;; Redistribution and use in source and binary forms, with or without
;;;; modification, are permitted provided that the following conditions are met:
;;;;
;;;;     * Redistributions of source code must retain the above copyright
;;;;       notice, this list of conditions and the following disclaimer.
;;;;
;;;;     * Redistributions in binary form must reproduce the above copyright
;;;;       notice, this list of conditions and the following disclaimer in the
;;;;       documentation and/or other materials provided with the distribution.
;;;;
;;;;     * Neither the name of Christopher Mark Gore nor the names of other
;;;;       contributors may be used to endorse or promote products derived from
;;;;       this software without specific prior written permission.
;;;;
;;;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;;;; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;;;; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;;;; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
;;;; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
;;;; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
;;;; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
;;;; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
;;;; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;;;; POSSIBILITY OF SUCH DAMAGE.

(uiop:define-package #:coingecko
  (:use #:common-lisp #:sigma/behave #:coingecko/rest-api)
  (:reexport #:coingecko/rest-api)
  (:export #:unix-epoch
           #:unix->universal
           #:universal->unix
           #:canonicalize-date
           #:canonicalize-unix
           #:quotes
           #:price
           #:market-chart
           #:market-chart-range
           #:ohlc
           #:ohlc-range
           #:history
           #:price-history
           #:ohlc-history
           #:fiat-rate
           #:1/fiat-rate
           #:btc/usd
           #:eth/usd
           #:xag/usd
           #:xau/usd
           #:btc/eth
           #:btc/xag
           #:btc/xau
           #:eth/btc
           #:eth/xag
           #:eth/xau
           #:/btc
           #:/eth
           #:/xag
           #:/xau))
(in-package #:coingecko)

(defparameter unix-epoch (encode-universal-time 0 0 0 1 1 1970 0)
  "Universal time of the UNIX epoch (1970-01-01T00:00:00Z).")

(defun unix->universal (unix)
  "Convert a UNIX timestamp in seconds or milliseconds to universal time.
Values above 10^11 are treated as milliseconds (CoinGecko chart points)."
  (let ((seconds (if (> unix 100000000000)
                     (floor unix 1000)
                     unix)))
    (+ seconds unix-epoch)))

(defun universal->unix (universal)
  "Convert a Common Lisp universal time to UNIX seconds."
  (- universal unix-epoch))

(defun canonicalize-date (date)
  "CoinGecko /history dates are YYYY-MM-DD.
Accepts a string, a universal time, or a (year month day) list."
  (cond ((null date) nil)
        ((stringp date) date)
        ((integerp date)
         (multiple-value-bind (second minute hour day month year)
             (decode-universal-time date 0)
           (declare (ignore second minute hour))
           (format nil "~4,'0D-~2,'0D-~2,'0D" year month day)))
        ((and (consp date) (= 3 (length date)))
         (format nil "~4,'0D-~2,'0D-~2,'0D"
                 (first date) (second date) (third date)))
        (t (princ-to-string date))))

(defun canonicalize-unix (value)
  "Turn VALUE into a UNIX-seconds string for range endpoints.
Integers greater than 10^10 are treated as milliseconds.
Integers greater than 3·10^9 are treated as universal times.
Everything else is passed through as unix seconds."
  (cond ((null value) nil)
        ((stringp value) value)
        ((integerp value)
         (princ-to-string
          (cond ((> value 100000000000) (floor value 1000))
                ((> value 3000000000) (universal->unix value))
                (t value))))
        (t (query-value value))))

(defun series-point (pair)
  "Convert a CoinGecko [unix-ms, value] pair to (universal-time value)."
  (list (unix->universal (elt pair 0))
        (elt pair 1)))

(defun quotes (&key (ids '(:bitcoin :ethereum))
                    (vs-currencies '(:usd :xag :xau)))
  "One cached /simple/price call covering the usual Limbic quote set."
  (get-simple-price :ids ids :vs-currencies vs-currencies))

(defun price (id &optional (vs-currency :usd))
  "Current price of ID in VS-CURRENCY.  ID may be :btc or \"bitcoin\"."
  (let* ((cid (canonicalize-coin-id id))
         (cvs (query-value vs-currency))
         (table (get-simple-price :ids cid :vs-currencies cvs)))
    (gethash cvs (gethash cid table))))

(defun market-chart (id &key (vs-currency :usd) (days 30) interval precision)
  "Raw /coins/{id}/market_chart payload (prices, market_caps, total_volumes)."
  (get-coin-market-chart id
                         :vs-currency vs-currency
                         :days days
                         :interval interval
                         :precision precision))

(defun market-chart-range (id &key (vs-currency :usd) from to interval precision)
  "Raw /coins/{id}/market_chart/range payload.  FROM and TO may be
universal times, UNIX seconds, or UNIX milliseconds."
  (get-coin-market-chart-range id
                               :vs-currency vs-currency
                               :from (canonicalize-unix from)
                               :to (canonicalize-unix to)
                               :interval interval
                               :precision precision))

(defun ohlc (id &key (vs-currency :usd) (days 30) interval precision)
  "Raw /coins/{id}/ohlc payload: a vector of [ts, open, high, low, close]."
  (get-coin-ohlc id
                 :vs-currency vs-currency
                 :days days
                 :interval interval
                 :precision precision))

(defun ohlc-range (id &key (vs-currency :usd) from to interval)
  "Raw /coins/{id}/ohlc/range payload.  Analyst plan and above."
  (get-coin-ohlc-range id
                       :vs-currency vs-currency
                       :from (canonicalize-unix from)
                       :to (canonicalize-unix to)
                       :interval interval))

(defun history (id date &key localization)
  "Snapshot of a coin at 00:00 UTC on DATE (YYYY-MM-DD, universal time,
or (year month day))."
  (get-coin-history id
                    :date (canonicalize-date date)
                    :localization localization))

(defun price-history (id &key (vs-currency :usd) (days 30) interval)
  "List of (universal-time price) points for ID.
This is the main Limbic entry point for Bitcoin (and other) histories."
  (map 'list #'series-point
       (gethash "prices"
                (market-chart id
                              :vs-currency vs-currency
                              :days days
                              :interval interval))))

(defun ohlc-history (id &key (vs-currency :usd) (days 30) interval)
  "List of (universal-time open high low close) candles for ID."
  (map 'list
       (lambda (bar)
         (list (unix->universal (elt bar 0))
               (elt bar 1)
               (elt bar 2)
               (elt bar 3)
               (elt bar 4)))
       (ohlc id :vs-currency vs-currency :days days :interval interval)))

(defun quote-vs (id vs-currency)
  (gethash (query-value vs-currency)
           (gethash (canonicalize-coin-id id) (quotes))))

(defun btc/usd ()
  "The value of Bitcoin in US Dollars."
  (quote-vs :bitcoin :usd))

(defun eth/usd ()
  "The value of Ether in US Dollars."
  (quote-vs :ethereum :usd))

(defun btc/xag ()
  "The value of Bitcoin in troy ounces of silver."
  (quote-vs :bitcoin :xag))

(defun btc/xau ()
  "The value of Bitcoin in troy ounces of gold."
  (quote-vs :bitcoin :xau))

(defun eth/xag ()
  "The value of Ether in troy ounces of silver."
  (quote-vs :ethereum :xag))

(defun eth/xau ()
  "The value of Ether in troy ounces of gold."
  (quote-vs :ethereum :xau))

(defun xag/usd ()
  "The value of one troy ounce of silver in US Dollars."
  (/ (btc/usd) (btc/xag)))

(defun xau/usd ()
  "The value of one troy ounce of gold in US Dollars."
  (/ (btc/usd) (btc/xau)))

(defun /btc (id)
  "The value of ID expressed in Bitcoin."
  (/ (price id :usd) (btc/usd)))

(defun /eth (id)
  "The value of ID expressed in Ether."
  (/ (price id :usd) (eth/usd)))

(defun /xag (id)
  "The value of ID expressed in troy ounces of silver."
  (/ (price id :usd) (xag/usd)))

(defun /xau (id)
  "The value of ID expressed in troy ounces of gold."
  (/ (price id :usd) (xau/usd)))

(defun btc/eth ()
  "The value of Bitcoin expressed in Ether."
  (/eth :bitcoin))

(defun eth/btc ()
  "The value of Ether expressed in Bitcoin."
  (/btc :ethereum))

(defun fiat-rate (symbol)
  "USD-per-unit for a vs_currency (:usd, :xag, :xau) or a coin (:btc, :eth).
Mirrors the Zapper-era name so Limbic call sites can switch over cleanly."
  (let ((key (query-value symbol)))
    (cond ((string= key "usd") 1)
          ((string= key "xag") (xag/usd))
          ((string= key "xau") (xau/usd))
          (t (price symbol :usd)))))

(defun 1/fiat-rate (symbol)
  "Units per US Dollar."
  (/ 1 (fiat-rate symbol)))

(behavior 'unix->universal
  (should= unix-epoch (unix->universal 0))
  (should= (+ unix-epoch 1) (unix->universal 1))
  (should= (encode-universal-time 0 0 0 1 1 2020 0)
           (unix->universal 1577836800))
  (should= (encode-universal-time 0 0 0 1 1 2020 0)
           (unix->universal 1577836800000)))

(behavior 'universal->unix
  (should= 0 (universal->unix unix-epoch))
  (should= 1577836800
           (universal->unix (encode-universal-time 0 0 0 1 1 2020 0)))
  (should= 1577836800
           (universal->unix (unix->universal 1577836800))))

(behavior 'canonicalize-date
  (should-string= "2024-01-15" (canonicalize-date "2024-01-15"))
  (should-string= "2020-01-01"
                  (canonicalize-date (encode-universal-time 0 0 0 1 1 2020 0)))
  (should-string= "2024-07-04" (canonicalize-date '(2024 7 4)))
  (should-be-null (canonicalize-date nil)))

(behavior 'canonicalize-unix
  (should-string= "1577836800" (canonicalize-unix 1577836800))
  (should-string= "1577836800" (canonicalize-unix 1577836800000))
  (should-string= "1577836800"
                  (canonicalize-unix (encode-universal-time 0 0 0 1 1 2020 0)))
  (should-be-null (canonicalize-unix nil)))

(behavior 'series-point
  (let ((point (series-point #(1577836800000 7200.5))))
    (should= (encode-universal-time 0 0 0 1 1 2020 0) (first point))
    (should= 7200.5 (second point))))
