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

;;;; Live CoinGecko checks.  Loaded only by TEST-OP when COINGECKO_LIVE_TESTS
;;;; is set in the environment, so ordinary loads never hit the network.

(in-package #:coingecko)

(behavior 'ping
  (let ((body (ping)))
    (should-be-a 'hash-table body)
    (should-be-true (gethash "gecko_says" body))))

(behavior 'price
  (let ((btc (price :bitcoin :usd))
        (also (price :btc :usd)))
    (should-be-a 'number btc)
    (should-be-true (plusp btc))
    (should= btc also)))

(behavior 'price-history
  (let ((history (price-history :bitcoin :vs-currency :usd :days 1)))
    (should-be-true (consp history))
    (should-be-true (>= (length history) 1))
    (let ((point (first history)))
      (should-be-a 'integer (first point))
      (should-be-a 'number (second point))
      (should-be-true (> (first point) unix-epoch)))))

(behavior 'ohlc-history
  (let ((bars (ohlc-history :bitcoin :vs-currency :usd :days 1)))
    (should-be-true (plusp (length bars)))
    (let ((bar (first bars)))
      (should= 5 (length bar))
      (should-be-a 'integer (first bar))
      (should-be-a 'number (second bar) (third bar) (fourth bar) (fifth bar)))))

(behavior 'btc/usd
  (should-be-a 'number (btc/usd))
  (should-be-true (plusp (btc/usd)))
  (should-be-a 'number (eth/usd))
  (should-be-true (plusp (xag/usd)))
  (should-be-true (plusp (xau/usd))))
