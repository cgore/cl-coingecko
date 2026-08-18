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

(defpackage #:coingecko/rest-api
  (:use :common-lisp :sigma/behave)
  (:export
           :*v3-public*
           :*v3-pro*
           :*api*
           :*api-key*
           :*api-plan*
           :*api-cache-timeout-seconds*
           :*max-retries*
           :*retry-wait-seconds*
           :*coin-id-aliases*
           :use-keyless
           :use-demo
           :use-pro
           :configure-from-environment
           :query-value
           :query
           :api-path
           :canonicalize-coin-id
           :canonicalize-ids
           :http-get
           :http-get-cached
           :http-get-json
           :http-get-json-cached
           :http-get-json-do-not-cache
           :api-get
           :http-status
           :http-body
           :api-error
           :rate-limited
           :plan-restricted
           :api-error-status
           :api-error-url
           :api-error-code
           :api-error-message
           :api-error-timestamp
           :api-error-body
           :parse-error-envelope
           :classify-error
           :api-error-from
           :ping
           :get-key
           :get-simple-price
           :get-token-price
           :get-supported-vs-currencies
           :get-coins-list
           :get-coins-list-new
           :get-coins-markets
           :get-coin
           :get-coin-tickers
           :get-coin-history
           :get-coin-market-chart
           :get-coin-market-chart-range
           :get-coin-ohlc
           :get-coin-ohlc-range
           :get-coin-by-contract
           :get-coin-market-chart-by-contract
           :get-coin-market-chart-range-by-contract
           :get-coin-circulating-supply-chart
           :get-coin-circulating-supply-chart-range
           :get-coin-total-supply-chart
           :get-coin-total-supply-chart-range
           :get-coin-supply-breakdown
           :get-top-gainers-losers
           :get-coins-categories-list
           :get-coins-categories
           :get-asset-platforms
           :get-token-list
           :get-exchanges
           :get-exchanges-list
           :get-exchange
           :get-exchange-tickers
           :get-exchange-volume-chart
           :get-exchange-volume-chart-range
           :get-derivatives
           :get-derivatives-exchanges
           :get-derivatives-exchange
           :get-derivatives-exchanges-list
           :get-entities-list
           :get-public-treasury-by-coin
           :get-public-treasury
           :get-public-treasury-holding-chart
           :get-public-treasury-transaction-history
           :get-nfts-list
           :get-nft
           :get-nft-by-contract
           :get-nfts-markets
           :get-nft-market-chart
           :get-nft-market-chart-by-contract
           :get-nft-tickers
           :get-search
           :get-trending
           :get-news
           :get-insights
           :get-global
           :get-global-defi
           :get-global-market-cap-chart
           :get-exchange-rates
           :get-onchain-token-price
           :get-onchain-pool
           :get-onchain-pools
           :get-onchain-pool-info
           :get-onchain-top-pools
           :get-onchain-top-pools-by-dex
           :get-onchain-top-pools-by-token
           :get-onchain-pools-megafilter
           :get-onchain-new-pools
           :get-onchain-new-pools-by-network
           :get-onchain-trending-pools
           :get-onchain-trending-pools-by-network
           :get-onchain-trending-search-pools
           :get-onchain-token
           :get-onchain-tokens
           :get-onchain-token-info
           :get-onchain-tokens-recently-updated
           :get-onchain-pool-ohlcv
           :get-onchain-token-ohlcv
           :get-onchain-pool-trades
           :get-onchain-token-trades
           :get-onchain-top-traders
           :get-onchain-top-holders
           :get-onchain-holders-chart
           :get-onchain-categories
           :get-onchain-category-pools
           :get-onchain-networks
           :get-onchain-dexes
           :get-onchain-search-pools))
(in-package :coingecko/rest-api)

(defvar *v3-public* "https://api.coingecko.com/api/v3")
(defvar *v3-pro*    "https://pro-api.coingecko.com/api/v3")

(defvar *api*       *v3-public*)
(defvar *api-plan*  :keyless
  "One of :KEYLESS, :DEMO, or :PRO.  Controls the host and the API-key header.")
(defvar *api-key*   nil
  "Demo or Pro API key.  Loaded from COINGECKO_PRO_API_KEY,
COINGECKO_DEMO_API_KEY, or COINGECKO_API_KEY when the system is loaded.")

(defvar *api-cache-timeout-seconds* 60)
(defvar *max-retries* 3)
(defvar *retry-wait-seconds* 2)

(defvar *coin-id-aliases*
  (sigma/hash:populate-hash-table
   "btc"  "bitcoin"
   "eth"  "ethereum"
   "sol"  "solana"
   "doge" "dogecoin"
   "ada"  "cardano"
   "dot"  "polkadot"
   "avax" "avalanche-2"
   "matic" "matic-network"
   "pol"  "polygon-ecosystem-token"
   "link" "chainlink"
   "uni"  "uniswap"
   "ltc"  "litecoin"
   "bch"  "bitcoin-cash"
   "xrp"  "ripple"
   "bnb"  "binancecoin"))

(defun use-keyless ()
  "Talk to the public host with no API key header."
  (setf *api-plan* :keyless
        *api*      *v3-public*)
  *api-plan*)

(defun use-demo (&optional key)
  "Talk to the public host with an x-cg-demo-api-key header."
  (when key (setf *api-key* key))
  (setf *api-plan* :demo
        *api*      *v3-public*)
  *api-plan*)

(defun use-pro (&optional key)
  "Talk to the Pro host with an x-cg-pro-api-key header."
  (when key (setf *api-key* key))
  (setf *api-plan* :pro
        *api*      *v3-pro*)
  *api-plan*)

(defun configure-from-environment ()
  "Pick :PRO, :DEMO, or :KEYLESS from the process environment."
  (let ((pro  (uiop:getenv "COINGECKO_PRO_API_KEY"))
        (demo (or (uiop:getenv "COINGECKO_DEMO_API_KEY")
                  (uiop:getenv "COINGECKO_API_KEY"))))
    (cond (pro  (use-pro pro))
          (demo (use-demo demo))
          (t    (use-keyless)))))

(defun api-key-headers ()
  (when (and *api-key* (not (eq *api-plan* :keyless)))
    (list (cons (if (eq *api-plan* :pro)
                    "x-cg-pro-api-key"
                    "x-cg-demo-api-key")
                *api-key*))))

(defun query-value (value)
  "Turn a Lisp value into a CoinGecko query-string fragment.
Lists and vectors become comma-separated.  T/:TRUE and :FALSE become
true/false.  Symbols are downcased.  Strings and numbers pass through."
  (cond ((eq value t)      "true")
        ((eq value :true)  "true")
        ((eq value :false) "false")
        ((null value)      nil)
        ((stringp value)   value)
        ((symbolp value)   (string-downcase (symbol-name value)))
        ((and (vectorp value) (not (stringp value)))
         (query-value (coerce value 'list)))
        ((listp value)
         (format nil "~{~A~^,~}" (mapcar #'query-value value)))
        (t (princ-to-string value))))

(defun query (&rest pairs)
  "Build a query list of (NAME VALUE) pairs from NAME VALUE ..., dropping NILs.
Pairs are proper lists so function-cache can hash them; HTTP-GET turns them
into an alist for QURI."
  (loop for (name value) on pairs by #'cddr
        for rendered = (query-value value)
        when rendered
        collect (list name rendered)))

(defun query-alist (query-args)
  (mapcar (lambda (pair)
            (if (and (consp pair) (consp (cdr pair)))
                (cons (first pair) (second pair))
                pair))
          query-args))

(defun path-segment (value)
  (cond ((null value) "")
        ((stringp value) value)
        ((symbolp value) (string-downcase (symbol-name value)))
        ((listp value)
         (format nil "~{~A~^,~}" (mapcar #'path-segment value)))
        ((and (vectorp value) (not (stringp value)))
         (path-segment (coerce value 'list)))
        (t (princ-to-string value))))

(defun api-path (&rest segments)
  "Join URL segments onto the API root path, e.g. (api-path \"coins\" :bitcoin \"market_chart\")."
  (format nil "~{/~A~}" (mapcar #'path-segment segments)))

(defun canonicalize-coin-id (id)
  "Downcase a coin id.  Known ticker symbols such as :BTC map to CoinGecko ids."
  (let ((raw (cond ((null id) nil)
                   ((stringp id) (string-downcase id))
                   ((symbolp id) (string-downcase (symbol-name id)))
                   (t (string-downcase (princ-to-string id))))))
    (or (and raw (gethash raw *coin-id-aliases*))
        raw)))

(defun canonicalize-ids (ids)
  "Canonicalize a single coin id or a list/vector of them."
  (cond ((null ids) nil)
        ((or (listp ids) (and (vectorp ids) (not (stringp ids))))
         (mapcar #'canonicalize-coin-id
                 (if (listp ids) ids (coerce ids 'list))))
        (t (canonicalize-coin-id ids))))

;;;; -- Error conditions ------------------------------------------------------
;; CoinGecko reports failures as an HTTP error (4xx, or 429 when rate-limited)
;; whose JSON body looks like:
;;   {"status": {"error_code": 10005,
;;               "error_message": "This request is limited to PRO API subscribers.",
;;               "timestamp": "2026-08-18T03:41:11.726+00:00"}}
;; We translate those into Lisp conditions so callers can handler-case on them
;; instead of unwrapping dexador internals.

(define-condition api-error (error)
  ((status :initform nil :initarg :status :reader api-error-status)
   (url :initform nil :initarg :url :reader api-error-url)
   (error-code :initform nil :initarg :error-code :reader api-error-code)
   (error-message :initform nil :initarg :error-message :reader api-error-message)
   (timestamp :initform nil :initarg :timestamp :reader api-error-timestamp)
   (body :initform nil :initarg :body :reader api-error-body))
  (:report (lambda (condition stream)
             (format stream "CoinGecko API error [HTTP ~A~A]: ~A (url: ~A)"
                     (or (api-error-status condition) "?")
                     (if (api-error-code condition)
                         (format nil ", code ~A" (api-error-code condition))
                         "")
                     (or (api-error-message condition) "unknown error")
                     (or (api-error-url condition) "?"))))
  (:documentation "An error returned by the CoinGecko API.
STATUS is the HTTP status code; ERROR-CODE, ERROR-MESSAGE, and TIMESTAMP come
from the \"status\" object in the JSON response body; URL is the request URI;
BODY is the raw response body."))

(define-condition rate-limited (api-error) ()
  (:documentation "HTTP 429 -- the request exceeded the plan's rate limit."))

(define-condition plan-restricted (api-error) ()
  (:documentation "The endpoint requires a paid (PRO/Analyst/Enterprise) plan."))

(defun http-status (condition)
  (let ((fn (or (and (find-symbol "RESPONSE-STATUS" :dexador)
                     (fboundp (find-symbol "RESPONSE-STATUS" :dexador))
                     (symbol-function (find-symbol "RESPONSE-STATUS" :dexador)))
                (and (find-symbol "RESPONSE-STATUS" :dex)
                     (fboundp (find-symbol "RESPONSE-STATUS" :dex))
                     (symbol-function (find-symbol "RESPONSE-STATUS" :dex))))))
    (when fn
      (ignore-errors (funcall fn condition)))))

(defun http-body (condition)
  "The response body of a dexador/dex response condition, if any."
  (let ((fn (or (and (find-symbol "RESPONSE-BODY" :dexador)
                     (fboundp (find-symbol "RESPONSE-BODY" :dexador))
                     (symbol-function (find-symbol "RESPONSE-BODY" :dexador)))
                (and (find-symbol "RESPONSE-BODY" :dex)
                     (fboundp (find-symbol "RESPONSE-BODY" :dex))
                     (symbol-function (find-symbol "RESPONSE-BODY" :dex))))))
    (when fn
      (ignore-errors (funcall fn condition)))))

(defun parse-error-envelope (body)
  "Return the inner \"status\" hash from a CoinGecko error BODY, or NIL.
BODY should be a JSON string of the form
  {\"status\": {\"error_code\": ..., \"error_message\": ..., \"timestamp\": ...}}"
  (when (stringp body)
    (ignore-errors
      (let* ((top (yason:parse body))
             (status (when (hash-table-p top) (gethash "status" top))))
        (when (hash-table-p status)
          status)))))

(defun classify-error (status code message)
  "Pick the api-error subclass for an HTTP STATUS and CoinGecko error CODE/MESSAGE."
  (cond ((= status 429) 'rate-limited)
        ((and (integerp code) (= code 10005)) 'plan-restricted)
        ((and message (search "PRO API subscribers" message)) 'plan-restricted)
        (t 'api-error)))

(defun api-error-from (status body url)
  "Build the appropriate api-error condition for an HTTP STATUS and response BODY."
  (let* ((env (parse-error-envelope body))
         (code (and env (gethash "error_code" env)))
         (msg (and env (gethash "error_message" env)))
         (ts (and env (gethash "timestamp" env)))
         (url (if (stringp url) url (format nil "~A" url))))
    (make-instance (classify-error status code msg)
                   :status status
                   :url url
                   :error-code code
                   :error-message (or msg
                                     (format nil "HTTP status ~A from ~A" status url))
                   :timestamp ts
                   :body body)))

(defun http-get (url-components &key (query-args '()))
  "Make an HTTP GET call to the CoinGecko API.  Retries 429s with backoff."
  (let ((uri (quri:make-uri :defaults (cond ((stringp url-components)
                                             (concatenate 'string *api* url-components))
                                            ((listp url-components)
                                             (apply #'concatenate 'string *api* url-components)))
                            :query (query-alist query-args)))
        (headers (api-key-headers)))
    (loop for attempt from 1 to *max-retries*
          do (handler-case
                 (return (if headers
                             (dex:get uri :headers headers)
                             (dex:get uri)))
               (error (condition)
                 (let ((status (http-status condition)))
                   (if (and status
                            (= status 429)
                            (< attempt *max-retries*))
                       (sleep (* *retry-wait-seconds* attempt))
                       (if status
                           (signal (api-error-from status (http-body condition) uri))
                           (error condition)))))))))

(function-cache:defcached
    (http-get-cached :timeout *api-cache-timeout-seconds*)
    (url-components &key (query-args '()))
  (http-get url-components :query-args query-args))

(defun http-get-json (url-components &key (query-args '()))
  "GET from CoinGecko, parse JSON.  Arrays become vectors; booleans become symbols."
  (let ((yason:*parse-json-arrays-as-vectors*   t)
        (yason:*parse-json-booleans-as-symbols* t))
    (yason:parse (http-get url-components :query-args query-args))))

(function-cache:defcached
    (http-get-json-cached :timeout *api-cache-timeout-seconds*)
    (url-components &key (query-args '()))
  (http-get-json url-components :query-args query-args))

(sigma/control:function-alias 'http-get-json 'http-get-json-do-not-cache)

(defun api-get (path &key query (cache t))
  "GET PATH (already rooted at /...) with QUERY alist.  CACHE defaults to T."
  (if cache
      (http-get-json-cached path :query-args query)
      (http-get-json path :query-args query)))

(behavior 'query-value
  (spec "booleans"
    (should-string= "true" (query-value t))
    (should-string= "true" (query-value :true))
    (should-string= "false" (query-value :false)))
  (spec "symbols and strings"
    (should-string= "usd" (query-value :usd))
    (should-string= "usd" (query-value "usd"))
    (should-string= "Bitcoin" (query-value "Bitcoin")))
  (spec "csv lists"
    (should-string= "bitcoin,ethereum" (query-value '("bitcoin" "ethereum")))
    (should-string= "usd,xag,xau" (query-value '(:usd :xag :xau))))
  (spec "numbers"
    (should-string= "30" (query-value 30))
    (should-string= "1.5" (query-value 1.5)))
  (spec "null"
    (should-be-null (query-value nil))))

(behavior 'query
  (should-equal '(("vs_currency" "usd") ("days" "30"))
                (query "vs_currency" :usd "days" 30 "interval" nil))
  (should-be-null (query "missing" nil)))

(behavior 'api-path
  (should-string= "/ping" (api-path "ping"))
  (should-string= "/coins/bitcoin/market_chart"
                  (api-path "coins" :bitcoin "market_chart"))
  (should-string= "/simple/token_price/ethereum"
                  (api-path "simple" "token_price" "ethereum"))
  (should-string= "/onchain/networks/eth/tokens/multi/0xabc,0xdef"
                  (api-path "onchain" "networks" "eth" "tokens" "multi"
                            '("0xabc" "0xdef"))))

(behavior 'canonicalize-coin-id
  (should-string= "bitcoin" (canonicalize-coin-id :bitcoin))
  (should-string= "bitcoin" (canonicalize-coin-id :btc))
  (should-string= "bitcoin" (canonicalize-coin-id "BTC"))
  (should-string= "ethereum" (canonicalize-coin-id :eth))
  (should-string= "solana" (canonicalize-coin-id :sol))
  (should-string= "wrapped-bitcoin" (canonicalize-coin-id "wrapped-bitcoin"))
  (should-be-null (canonicalize-coin-id nil)))

(behavior 'canonicalize-ids
  (should-string= "bitcoin" (canonicalize-ids :btc))
  (should-equal '("bitcoin" "ethereum") (canonicalize-ids '(:btc :eth)))
  (should-be-null (canonicalize-ids nil)))

(behavior 'use-keyless
  (let ((*api-plan* *api-plan*)
        (*api* *api*)
        (*api-key* *api-key*))
    (use-keyless)
    (should-eq :keyless *api-plan*)
    (should-string= *v3-public* *api*)
    (should-be-null (api-key-headers))))

(behavior 'use-demo
  (let ((*api-plan* *api-plan*)
        (*api* *api*)
        (*api-key* *api-key*))
    (use-demo "demo-secret")
    (should-eq :demo *api-plan*)
    (should-string= *v3-public* *api*)
    (should-string= "demo-secret" *api-key*)
    (should-equal '(("x-cg-demo-api-key" . "demo-secret"))
                  (api-key-headers))))

(behavior 'use-pro
  (let ((*api-plan* *api-plan*)
        (*api* *api*)
        (*api-key* *api-key*))
    (use-pro "pro-secret")
    (should-eq :pro *api-plan*)
    (should-string= *v3-pro* *api*)
    (should-string= "pro-secret" *api-key*)
    (should-equal '(("x-cg-pro-api-key" . "pro-secret"))
                  (api-key-headers))))

;;;; Utility, simple price, coins, markets, charts

(defun ping (&key (cache t))
  "GET /ping
Check the API server status."
  (api-get (api-path "ping")
           :query nil
           :cache cache))

(defun get-key (&key (cache nil))
  "GET /key
Monitor account API usage (rate limits, monthly credits)."
  (api-get (api-path "key")
           :query nil
           :cache cache))

(defun get-simple-price (&key vs-currencies ids names symbols include-tokens include-market-cap include-24hr-vol include-24hr-change include-last-updated-at precision (cache t))
  "GET /simple/price
Prices of one or more coins by CoinGecko IDs, names, or symbols."
  (api-get (api-path "simple" "price")
           :query (query "vs_currencies" vs-currencies
                         "ids" (canonicalize-ids ids)
                         "names" names "symbols" symbols
                         "include_tokens" include-tokens
                         "include_market_cap" include-market-cap
                         "include_24hr_vol" include-24hr-vol
                         "include_24hr_change" include-24hr-change
                         "include_last_updated_at" include-last-updated-at
                         "precision" precision)
           :cache cache))

(defun get-token-price (id &key contract-addresses vs-currencies include-market-cap include-24hr-vol include-24hr-change include-last-updated-at precision (cache t))
  "GET /simple/token_price/{id}
Token prices by contract addresses on an asset platform."
  (api-get (api-path "simple" "token_price" id)
           :query (query "contract_addresses" contract-addresses "vs_currencies" vs-currencies "include_market_cap" include-market-cap "include_24hr_vol" include-24hr-vol "include_24hr_change" include-24hr-change "include_last_updated_at" include-last-updated-at "precision" precision)
           :cache cache))

(defun get-supported-vs-currencies (&key (cache t))
  "GET /simple/supported_vs_currencies
All supported vs_currencies values (usd, xau, xag, ...)."
  (api-get (api-path "simple" "supported_vs_currencies")
           :query nil
           :cache cache))

(defun get-coins-list (&key include-platform status (cache t))
  "GET /coins/list
All supported coins with CoinGecko id, name, and symbol."
  (api-get (api-path "coins" "list")
           :query (query "include_platform" include-platform "status" status)
           :cache cache))

(defun get-coins-list-new (&key (cache t))
  "GET /coins/list/new
The latest 200 coins recently listed on CoinGecko. Analyst plan and above."
  (api-get (api-path "coins" "list" "new")
           :query nil
           :cache cache))

(defun get-coins-markets (&key vs-currency ids names symbols include-tokens category order per-page page sparkline price-change-percentage locale precision include-rehypothecated (cache t))
  "GET /coins/markets
Coins with price, market cap, volume, and related market data."
  (api-get (api-path "coins" "markets")
           :query (query "vs_currency" vs-currency
                         "ids" (canonicalize-ids ids)
                         "names" names "symbols" symbols
                         "include_tokens" include-tokens
                         "category" category "order" order
                         "per_page" per-page "page" page
                         "sparkline" sparkline
                         "price_change_percentage" price-change-percentage
                         "locale" locale "precision" precision
                         "include_rehypothecated" include-rehypothecated)
           :cache cache))

(defun get-coin (id &key localization tickers market-data community-data developer-data sparkline include-categories-details dex-pair-format (cache t))
  "GET /coins/{id}
Metadata and market data for a coin by CoinGecko id."
  (api-get (api-path "coins" (canonicalize-coin-id id))
           :query (query "localization" localization "tickers" tickers "market_data" market-data "community_data" community-data "developer_data" developer-data "sparkline" sparkline "include_categories_details" include-categories-details "dex_pair_format" dex-pair-format)
           :cache cache))

(defun get-coin-tickers (id &key exchange-ids include-exchange-logo page order depth dex-pair-format (cache t))
  "GET /coins/{id}/tickers
CEX and DEX tickers for a coin."
  (api-get (api-path "coins" (canonicalize-coin-id id) "tickers")
           :query (query "exchange_ids" exchange-ids "include_exchange_logo" include-exchange-logo "page" page "order" order "depth" depth "dex_pair_format" dex-pair-format)
           :cache cache))

(defun get-coin-history (id &key date localization (cache t))
  "GET /coins/{id}/history
Snapshot of price, market cap, and volume at 00:00 UTC on DATE (YYYY-MM-DD)."
  (api-get (api-path "coins" (canonicalize-coin-id id) "history")
           :query (query "date" date "localization" localization)
           :cache cache))

(defun get-coin-market-chart (id &key vs-currency days interval precision (cache t))
  "GET /coins/{id}/market_chart
Historical chart series: prices, market_caps, total_volumes."
  (api-get (api-path "coins" (canonicalize-coin-id id) "market_chart")
           :query (query "vs_currency" vs-currency "days" days "interval" interval "precision" precision)
           :cache cache))

(defun get-coin-market-chart-range (id &key vs-currency from to interval precision (cache t))
  "GET /coins/{id}/market_chart/range
Historical chart series between UNIX FROM and TO."
  (api-get (api-path "coins" (canonicalize-coin-id id) "market_chart" "range")
           :query (query "vs_currency" vs-currency "from" from "to" to "interval" interval "precision" precision)
           :cache cache))

(defun get-coin-ohlc (id &key vs-currency days interval precision (cache t))
  "GET /coins/{id}/ohlc
OHLC candles [timestamp, open, high, low, close] by coin id."
  (api-get (api-path "coins" (canonicalize-coin-id id) "ohlc")
           :query (query "vs_currency" vs-currency "days" days "interval" interval "precision" precision)
           :cache cache))

(defun get-coin-ohlc-range (id &key vs-currency from to interval (cache t))
  "GET /coins/{id}/ohlc/range
OHLC candles between UNIX FROM and TO. Analyst plan and above."
  (api-get (api-path "coins" (canonicalize-coin-id id) "ohlc" "range")
           :query (query "vs_currency" vs-currency "from" from "to" to "interval" interval)
           :cache cache))

(defun get-coin-by-contract (id contract-address &key (cache t))
  "GET /coins/{id}/contract/{contract_address}
Coin metadata and market data by asset platform and contract address."
  (api-get (api-path "coins" id "contract" contract-address)
           :query nil
           :cache cache))

(defun get-coin-market-chart-by-contract (id contract-address &key vs-currency days interval precision (cache t))
  "GET /coins/{id}/contract/{contract_address}/market_chart
Historical chart series by asset platform and contract address."
  (api-get (api-path "coins" id "contract" contract-address "market_chart")
           :query (query "vs_currency" vs-currency "days" days "interval" interval "precision" precision)
           :cache cache))

(defun get-coin-market-chart-range-by-contract (id contract-address &key vs-currency from to interval precision (cache t))
  "GET /coins/{id}/contract/{contract_address}/market_chart/range
Historical chart series in a UNIX range by contract address."
  (api-get (api-path "coins" id "contract" contract-address "market_chart" "range")
           :query (query "vs_currency" vs-currency "from" from "to" to "interval" interval "precision" precision)
           :cache cache))

(defun get-coin-circulating-supply-chart (id &key days interval (cache t))
  "GET /coins/{id}/circulating_supply_chart
Historical circulating supply. Enterprise plan."
  (api-get (api-path "coins" (canonicalize-coin-id id) "circulating_supply_chart")
           :query (query "days" days "interval" interval)
           :cache cache))

(defun get-coin-circulating-supply-chart-range (id &key from to (cache t))
  "GET /coins/{id}/circulating_supply_chart/range
Historical circulating supply in a UNIX range. Enterprise plan."
  (api-get (api-path "coins" (canonicalize-coin-id id) "circulating_supply_chart" "range")
           :query (query "from" from "to" to)
           :cache cache))

(defun get-coin-total-supply-chart (id &key days interval (cache t))
  "GET /coins/{id}/total_supply_chart
Historical total supply. Enterprise plan."
  (api-get (api-path "coins" (canonicalize-coin-id id) "total_supply_chart")
           :query (query "days" days "interval" interval)
           :cache cache))

(defun get-coin-total-supply-chart-range (id &key from to (cache t))
  "GET /coins/{id}/total_supply_chart/range
Historical total supply in a UNIX range. Enterprise plan."
  (api-get (api-path "coins" (canonicalize-coin-id id) "total_supply_chart" "range")
           :query (query "from" from "to" to)
           :cache cache))

(defun get-coin-supply-breakdown (id &key (cache t))
  "GET /coins/{id}/supply_breakdown
Supply breakdown for a coin. Analyst plan and above."
  (api-get (api-path "coins" (canonicalize-coin-id id) "supply_breakdown")
           :query nil
           :cache cache))

(defun get-top-gainers-losers (&key vs-currency duration price-change-percentage top-coins (cache t))
  "GET /coins/top_gainers_losers
Top 30 gainers and losers. Analyst plan and above."
  (api-get (api-path "coins" "top_gainers_losers")
           :query (query "vs_currency" vs-currency "duration" duration "price_change_percentage" price-change-percentage "top_coins" top-coins)
           :cache cache))

(defun get-coins-categories-list (&key (cache t))
  "GET /coins/categories/list
All supported coin categories (id and name)."
  (api-get (api-path "coins" "categories" "list")
           :query nil
           :cache cache))

(defun get-coins-categories (&key order (cache t))
  "GET /coins/categories
Coin categories with market data."
  (api-get (api-path "coins" "categories")
           :query (query "order" order)
           :cache cache))

(defun get-asset-platforms (&key filter (cache t))
  "GET /asset_platforms
Supported asset platforms (blockchain networks)."
  (api-get (api-path "asset_platforms")
           :query (query "filter" filter)
           :cache cache))

(defun get-token-list (asset-platform-id &key (cache t))
  "GET /token_lists/{asset_platform_id}/all.json
Full token list for an asset platform (tokenlists.org format)."
  (api-get (api-path "token_lists" asset-platform-id "all.json")
           :query nil
           :cache cache))

(defun get-exchanges (&key per-page page (cache t))
  "GET /exchanges
Exchanges with volume and related data."
  (api-get (api-path "exchanges")
           :query (query "per_page" per-page "page" page)
           :cache cache))

(defun get-exchanges-list (&key status (cache t))
  "GET /exchanges/list
Exchanges with id and name."
  (api-get (api-path "exchanges" "list")
           :query (query "status" status)
           :cache cache))

(defun get-exchange (id &key dex-pair-format (cache t))
  "GET /exchanges/{id}
Exchange data and top 100 tickers."
  (api-get (api-path "exchanges" id)
           :query (query "dex_pair_format" dex-pair-format)
           :cache cache))

(defun get-exchange-tickers (id &key coin-ids include-exchange-logo page depth order dex-pair-format (cache t))
  "GET /exchanges/{id}/tickers
Tickers for an exchange."
  (api-get (api-path "exchanges" id "tickers")
           :query (query "coin_ids" coin-ids "include_exchange_logo" include-exchange-logo "page" page "depth" depth "order" order "dex_pair_format" dex-pair-format)
           :cache cache))

(defun get-exchange-volume-chart (id &key days (cache t))
  "GET /exchanges/{id}/volume_chart
Historical exchange volume in BTC."
  (api-get (api-path "exchanges" id "volume_chart")
           :query (query "days" days)
           :cache cache))

(defun get-exchange-volume-chart-range (id &key from to (cache t))
  "GET /exchanges/{id}/volume_chart/range
Historical exchange volume in BTC between UNIX FROM and TO. Analyst plan and above."
  (api-get (api-path "exchanges" id "volume_chart" "range")
           :query (query "from" from "to" to)
           :cache cache))

(defun get-derivatives (&key (cache t))
  "GET /derivatives
All derivative tickers."
  (api-get (api-path "derivatives")
           :query nil
           :cache cache))

(defun get-derivatives-exchanges (&key order per-page page (cache t))
  "GET /derivatives/exchanges
Derivatives exchanges with open interest and volume."
  (api-get (api-path "derivatives" "exchanges")
           :query (query "order" order "per_page" per-page "page" page)
           :cache cache))

(defun get-derivatives-exchange (id &key include-tickers (cache t))
  "GET /derivatives/exchanges/{id}
Derivatives exchange data by id."
  (api-get (api-path "derivatives" "exchanges" id)
           :query (query "include_tickers" include-tickers)
           :cache cache))

(defun get-derivatives-exchanges-list (&key (cache t))
  "GET /derivatives/exchanges/list
Derivatives exchanges with id and name."
  (api-get (api-path "derivatives" "exchanges" "list")
           :query nil
           :cache cache))

(defun get-entities-list (&key entity-type per-page page (cache t))
  "GET /entities/list
Public companies and governments tracked for treasury holdings."
  (api-get (api-path "entities" "list")
           :query (query "entity_type" entity-type "per_page" per-page "page" page)
           :cache cache))

(defun get-public-treasury-by-coin (entity coin-id &key per-page page order (cache t))
  "GET /{entity}/public_treasury/{coin_id}
Public treasury holdings by entity type (companies or governments) and coin."
  (api-get (api-path entity "public_treasury" coin-id)
           :query (query "per_page" per-page "page" page "order" order)
           :cache cache))

(defun get-public-treasury (entity-id &key holding-amount-change holding-change-percentage (cache t))
  "GET /public_treasury/{entity_id}
Public treasury holdings by entity id."
  (api-get (api-path "public_treasury" entity-id)
           :query (query "holding_amount_change" holding-amount-change "holding_change_percentage" holding-change-percentage)
           :cache cache))

(defun get-public-treasury-holding-chart (entity-id coin-id &key days include-empty-intervals (cache t))
  "GET /public_treasury/{entity_id}/{coin_id}/holding_chart
Historical treasury holdings chart."
  (api-get (api-path "public_treasury" entity-id coin-id "holding_chart")
           :query (query "days" days "include_empty_intervals" include-empty-intervals)
           :cache cache))

(defun get-public-treasury-transaction-history (entity-id &key per-page page order coin-ids (cache t))
  "GET /public_treasury/{entity_id}/transaction_history
Treasury transaction history for an entity."
  (api-get (api-path "public_treasury" entity-id "transaction_history")
           :query (query "per_page" per-page "page" page "order" order "coin_ids" coin-ids)
           :cache cache))

(defun get-nfts-list (&key order per-page page (cache t))
  "GET /nfts/list
Supported NFT collections (id, contract, name, platform, symbol)."
  (api-get (api-path "nfts" "list")
           :query (query "order" order "per_page" per-page "page" page)
           :cache cache))

(defun get-nft (id &key (cache t))
  "GET /nfts/{id}
NFT collection data (floor, volume, ...) by collection id."
  (api-get (api-path "nfts" id)
           :query nil
           :cache cache))

(defun get-nft-by-contract (asset-platform-id contract-address &key (cache t))
  "GET /nfts/{asset_platform_id}/contract/{contract_address}
NFT collection data by asset platform and contract address."
  (api-get (api-path "nfts" asset-platform-id "contract" contract-address)
           :query nil
           :cache cache))

(defun get-nfts-markets (&key asset-platform-id order per-page page (cache t))
  "GET /nfts/markets
NFT collections with floor, market cap, and volume. Analyst plan and above."
  (api-get (api-path "nfts" "markets")
           :query (query "asset_platform_id" asset-platform-id "order" order "per_page" per-page "page" page)
           :cache cache))

(defun get-nft-market-chart (id &key days (cache t))
  "GET /nfts/{id}/market_chart
Historical NFT floor, market cap, and volume. Analyst plan and above."
  (api-get (api-path "nfts" id "market_chart")
           :query (query "days" days)
           :cache cache))

(defun get-nft-market-chart-by-contract (asset-platform-id contract-address &key days (cache t))
  "GET /nfts/{asset_platform_id}/contract/{contract_address}/market_chart
Historical NFT market data by contract. Analyst plan and above."
  (api-get (api-path "nfts" asset-platform-id "contract" contract-address "market_chart")
           :query (query "days" days)
           :cache cache))

(defun get-nft-tickers (id &key (cache t))
  "GET /nfts/{id}/tickers
Latest floor and 24h volume per NFT marketplace. Analyst plan and above."
  (api-get (api-path "nfts" id "tickers")
           :query nil
           :cache cache))

(defun get-search (&key query (cache t))
  "GET /search
Search coins, categories, and markets."
  (api-get (api-path "search")
           :query (query "query" query)
           :cache cache))

(defun get-trending (&key show-max (cache t))
  "GET /search/trending
Trending coins, NFTs, and categories in the last 24 hours."
  (api-get (api-path "search" "trending")
           :query (query "show_max" show-max)
           :cache cache))

(defun get-news (&key page per-page coin-id language type (cache t))
  "GET /news
Latest CoinGecko news and guides. Analyst plan and above."
  (api-get (api-path "news")
           :query (query "page" page "per_page" per-page "coin_id" coin-id "language" language "type" type)
           :cache cache))

(defun get-insights (&key page per-page coin-id from to (cache t))
  "GET /insights
Latest coin insights. Enterprise plan."
  (api-get (api-path "insights")
           :query (query "page" page "per_page" per-page "coin_id" coin-id "from" from "to" to)
           :cache cache))

(defun get-global (&key (cache t))
  "GET /global
Global crypto stats: active coins, markets, total market cap."
  (api-get (api-path "global")
           :query nil
           :cache cache))

(defun get-global-defi (&key (cache t))
  "GET /global/decentralized_finance_defi
Global DeFi market cap and volume (top 100)."
  (api-get (api-path "global" "decentralized_finance_defi")
           :query nil
           :cache cache))

(defun get-global-market-cap-chart (&key days vs-currency (cache t))
  "GET /global/market_cap_chart
Historical global market cap and volume. Analyst plan and above."
  (api-get (api-path "global" "market_cap_chart")
           :query (query "days" days "vs_currency" vs-currency)
           :cache cache))

(defun get-exchange-rates (&key (cache t))
  "GET /exchange_rates
BTC-denominated exchange rates versus fiat, crypto, and commodities."
  (api-get (api-path "exchange_rates")
           :query nil
           :cache cache))

;;;; -- Error conditions ------------------------------------------------------

(defparameter *fixture-error-401*
  "{\"status\":{\"timestamp\":\"2026-08-18T03:41:11.726+00:00\",\"error_code\":10005,\"error_message\":\"This request is limited to PRO API subscribers. Please visit https://www.coingecko.com/en/api/pricing to subscribe to our API plan to access exclusive endpoints.\"}}"
  "A CoinGecko 401 error body, captured verbatim from a keyless GET /coins/list/new.")

(behavior 'parse-error-envelope
  (spec "401 PRO-subscribers body"
    (let ((env (parse-error-envelope *fixture-error-401*)))
      (should-be-a 'hash-table env)
      (should= 10005 (gethash "error_code" env))
      (should-string= "2026-08-18T03:41:11.726+00:00" (gethash "timestamp" env))
      (should-be-true (search "PRO API subscribers"
                                     (gethash "error_message" env)))))
  (spec "non-envelope input"
    (should-be-null (parse-error-envelope nil))
    (should-be-null (parse-error-envelope ""))
    (should-be-null (parse-error-envelope "not json at all"))
    (should-be-null (parse-error-envelope "{\"other\":1}"))))

(behavior 'classify-error
  (spec "rate limiting"
    (should-eq 'rate-limited (classify-error 429 nil nil)))
  (spec "plan restriction"
    (should-eq 'plan-restricted (classify-error 401 10005 nil))
    (should-eq 'plan-restricted
               (classify-error 401 nil
                               "This request is limited to PRO API subscribers.")))
  (spec "other errors"
    (should-eq 'api-error (classify-error 404 nil "Not Found"))
    (should-eq 'api-error (classify-error 500 nil nil))
    (should-eq 'api-error (classify-error 401 10001 "Invalid API key"))))

(behavior 'api-error-from
  (spec "401 fixture becomes plan-restricted"
    (let ((c (api-error-from 401 *fixture-error-401*
                             "https://api.coingecko.com/api/v3/coins/list/new")))
      (should-be-a 'plan-restricted c)
      (should-be-a 'api-error c)
      (should= 401 (api-error-status c))
      (should= 10005 (api-error-code c))
      (should-be-true (search "PRO API subscribers" (api-error-message c)))
      (should-string= "2026-08-18T03:41:11.726+00:00" (api-error-timestamp c))
      (should-string= *fixture-error-401* (api-error-body c))
      (should-string= "https://api.coingecko.com/api/v3/coins/list/new"
                      (api-error-url c))))
  (spec "429 becomes rate-limited"
    (let ((c (api-error-from 429 nil
                             "https://api.coingecko.com/api/v3/simple/price")))
      (should-be-a 'rate-limited c)
      (should-be-a 'api-error c)
      (should-be-false (typep c 'plan-restricted))
      (should= 429 (api-error-status c))
      (should-be-null (api-error-code c))))
  (spec "unparseable body becomes a generic api-error"
    (let ((c (api-error-from 404 "garbage"
                             "https://api.coingecko.com/api/v3/coins/nope")))
      (should-be-a 'api-error c)
      (should-be-false (typep c 'plan-restricted))
      (should-be-false (typep c 'rate-limited))
      (should= 404 (api-error-status c))
      (should-be-null (api-error-code c))
      (should-be-true (search "404" (api-error-message c))))))

(configure-from-environment)
