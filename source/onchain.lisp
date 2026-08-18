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

(in-package :coingecko/rest-api)

;;;; Onchain / GeckoTerminal

(defun get-onchain-token-price (network addresses &key include-market-cap mcap-fdv-fallback include-24hr-vol include-24hr-price-change include-total-reserve-in-usd include-inactive-source (cache t))
  "GET /onchain/simple/networks/{network}/token_price/{addresses}
Onchain token prices by network and contract addresses."
  (api-get (api-path "onchain" "simple" "networks" network "token_price" addresses)
           :query (query "include_market_cap" include-market-cap "mcap_fdv_fallback" mcap-fdv-fallback "include_24hr_vol" include-24hr-vol "include_24hr_price_change" include-24hr-price-change "include_total_reserve_in_usd" include-total-reserve-in-usd "include_inactive_source" include-inactive-source)
           :cache cache))

(defun get-onchain-pool (network address &key include include-volume-breakdown include-composition (cache t))
  "GET /onchain/networks/{network}/pools/{address}
A specific pool by network and pool address."
  (api-get (api-path "onchain" "networks" network "pools" address)
           :query (query "include" include "include_volume_breakdown" include-volume-breakdown "include_composition" include-composition)
           :cache cache))

(defun get-onchain-pools (network addresses &key include include-volume-breakdown include-composition (cache t))
  "GET /onchain/networks/{network}/pools/multi/{addresses}
Multiple pools by network and pool addresses."
  (api-get (api-path "onchain" "networks" network "pools" "multi" addresses)
           :query (query "include" include "include_volume_breakdown" include-volume-breakdown "include_composition" include-composition)
           :cache cache))

(defun get-onchain-pool-info (network pool-address &key include (cache t))
  "GET /onchain/networks/{network}/pools/{pool_address}/info
Pool metadata (tokens, socials, websites) by pool address."
  (api-get (api-path "onchain" "networks" network "pools" pool-address "info")
           :query (query "include" include)
           :cache cache))

(defun get-onchain-top-pools (network &key include page sort include-gt-community-data (cache t))
  "GET /onchain/networks/{network}/pools
Top pools on a network."
  (api-get (api-path "onchain" "networks" network "pools")
           :query (query "include" include "page" page "sort" sort "include_gt_community_data" include-gt-community-data)
           :cache cache))

(defun get-onchain-top-pools-by-dex (network dex &key include page sort include-gt-community-data (cache t))
  "GET /onchain/networks/{network}/dexes/{dex}/pools
Top pools on a network and DEX."
  (api-get (api-path "onchain" "networks" network "dexes" dex "pools")
           :query (query "include" include "page" page "sort" sort "include_gt_community_data" include-gt-community-data)
           :cache cache))

(defun get-onchain-top-pools-by-token (network token-address &key include include-inactive-source page sort include-gt-community-data (cache t))
  "GET /onchain/networks/{network}/tokens/{token_address}/pools
Top pools for a token contract."
  (api-get (api-path "onchain" "networks" network "tokens" token-address "pools")
           :query (query "include" include "include_inactive_source" include-inactive-source "page" page "sort" sort "include_gt_community_data" include-gt-community-data)
           :cache cache))

(defun get-onchain-pools-megafilter (&key networks dexes include page sort fdv-usd-min fdv-usd-max reserve-in-usd-min reserve-in-usd-max h24-volume-usd-min h24-volume-usd-max pool-created-hour-min pool-created-hour-max tx-count-min tx-count-max tx-count-duration buys-min buys-max buys-duration sells-min sells-max sells-duration price-change-percentage-min price-change-percentage-max price-change-percentage-duration buy-tax-percentage-min buy-tax-percentage-max sell-tax-percentage-min sell-tax-percentage-max holder-count-min holder-count-max top-10-holders-percentage-min top-10-holders-percentage-max checks include-unknown-honeypot-tokens (cache t))
  "GET /onchain/pools/megafilter
Filter pools across networks. Analyst plan and above."
  (api-get (api-path "onchain" "pools" "megafilter")
           :query (query "networks" networks "dexes" dexes "include" include "page" page "sort" sort "fdv_usd_min" fdv-usd-min "fdv_usd_max" fdv-usd-max "reserve_in_usd_min" reserve-in-usd-min "reserve_in_usd_max" reserve-in-usd-max "h24_volume_usd_min" h24-volume-usd-min "h24_volume_usd_max" h24-volume-usd-max "pool_created_hour_min" pool-created-hour-min "pool_created_hour_max" pool-created-hour-max "tx_count_min" tx-count-min "tx_count_max" tx-count-max "tx_count_duration" tx-count-duration "buys_min" buys-min "buys_max" buys-max "buys_duration" buys-duration "sells_min" sells-min "sells_max" sells-max "sells_duration" sells-duration "price_change_percentage_min" price-change-percentage-min "price_change_percentage_max" price-change-percentage-max "price_change_percentage_duration" price-change-percentage-duration "buy_tax_percentage_min" buy-tax-percentage-min "buy_tax_percentage_max" buy-tax-percentage-max "sell_tax_percentage_min" sell-tax-percentage-min "sell_tax_percentage_max" sell-tax-percentage-max "holder_count_min" holder-count-min "holder_count_max" holder-count-max "top_10_holders_percentage_min" top-10-holders-percentage-min "top_10_holders_percentage_max" top-10-holders-percentage-max "checks" checks "include_unknown_honeypot_tokens" include-unknown-honeypot-tokens)
           :cache cache))

(defun get-onchain-new-pools (&key include page include-gt-community-data (cache t))
  "GET /onchain/networks/new_pools
Newest pools across all networks."
  (api-get (api-path "onchain" "networks" "new_pools")
           :query (query "include" include "page" page "include_gt_community_data" include-gt-community-data)
           :cache cache))

(defun get-onchain-new-pools-by-network (network &key include page include-gt-community-data (cache t))
  "GET /onchain/networks/{network}/new_pools
Newest pools on a network."
  (api-get (api-path "onchain" "networks" network "new_pools")
           :query (query "include" include "page" page "include_gt_community_data" include-gt-community-data)
           :cache cache))

(defun get-onchain-trending-pools (&key include page duration include-gt-community-data (cache t))
  "GET /onchain/networks/trending_pools
Trending pools across all networks."
  (api-get (api-path "onchain" "networks" "trending_pools")
           :query (query "include" include "page" page "duration" duration "include_gt_community_data" include-gt-community-data)
           :cache cache))

(defun get-onchain-trending-pools-by-network (network &key include page duration include-gt-community-data (cache t))
  "GET /onchain/networks/{network}/trending_pools
Trending pools on a network."
  (api-get (api-path "onchain" "networks" network "trending_pools")
           :query (query "include" include "page" page "duration" duration "include_gt_community_data" include-gt-community-data)
           :cache cache))

(defun get-onchain-trending-search-pools (&key include pools (cache t))
  "GET /onchain/pools/trending_search
Trending search pools. Analyst plan and above."
  (api-get (api-path "onchain" "pools" "trending_search")
           :query (query "include" include "pools" pools)
           :cache cache))

(defun get-onchain-token (network address &key include include-composition include-inactive-source (cache t))
  "GET /onchain/networks/{network}/tokens/{address}
Token data by contract address on a network."
  (api-get (api-path "onchain" "networks" network "tokens" address)
           :query (query "include" include "include_composition" include-composition "include_inactive_source" include-inactive-source)
           :cache cache))

(defun get-onchain-tokens (network addresses &key include include-composition include-inactive-source (cache t))
  "GET /onchain/networks/{network}/tokens/multi/{addresses}
Multiple tokens by contract addresses on a network."
  (api-get (api-path "onchain" "networks" network "tokens" "multi" addresses)
           :query (query "include" include "include_composition" include-composition "include_inactive_source" include-inactive-source)
           :cache cache))

(defun get-onchain-token-info (network address &key (cache t))
  "GET /onchain/networks/{network}/tokens/{address}/info
Token metadata (name, symbol, CoinGecko id, socials) by contract."
  (api-get (api-path "onchain" "networks" network "tokens" address "info")
           :query nil
           :cache cache))

(defun get-onchain-tokens-recently-updated (&key include network (cache t))
  "GET /onchain/tokens/info_recently_updated
100 most recently updated tokens."
  (api-get (api-path "onchain" "tokens" "info_recently_updated")
           :query (query "include" include "network" network)
           :cache cache))

(defun get-onchain-pool-ohlcv (network pool-address timeframe &key aggregate before-timestamp limit currency token include-empty-intervals (cache t))
  "GET /onchain/networks/{network}/pools/{pool_address}/ohlcv/{timeframe}
Pool OHLCV candles. TIMEFRAME is day, hour, minute, or second."
  (api-get (api-path "onchain" "networks" network "pools" pool-address "ohlcv" timeframe)
           :query (query "aggregate" aggregate "before_timestamp" before-timestamp "limit" limit "currency" currency "token" token "include_empty_intervals" include-empty-intervals)
           :cache cache))

(defun get-onchain-token-ohlcv (network token-address timeframe &key aggregate before-timestamp limit currency include-empty-intervals include-inactive-source (cache t))
  "GET /onchain/networks/{network}/tokens/{token_address}/ohlcv/{timeframe}
Token OHLCV candles. Analyst plan and above."
  (api-get (api-path "onchain" "networks" network "tokens" token-address "ohlcv" timeframe)
           :query (query "aggregate" aggregate "before_timestamp" before-timestamp "limit" limit "currency" currency "include_empty_intervals" include-empty-intervals "include_inactive_source" include-inactive-source)
           :cache cache))

(defun get-onchain-pool-trades (network pool-address &key trade-volume-in-usd-greater-than token (cache t))
  "GET /onchain/networks/{network}/pools/{pool_address}/trades
Last 300 trades in the past 24 hours for a pool."
  (api-get (api-path "onchain" "networks" network "pools" pool-address "trades")
           :query (query "trade_volume_in_usd_greater_than" trade-volume-in-usd-greater-than "token" token)
           :cache cache))

(defun get-onchain-token-trades (network token-address &key trade-volume-in-usd-greater-than (cache t))
  "GET /onchain/networks/{network}/tokens/{token_address}/trades
Last 300 trades in the past 24 hours across pools. Analyst plan and above."
  (api-get (api-path "onchain" "networks" network "tokens" token-address "trades")
           :query (query "trade_volume_in_usd_greater_than" trade-volume-in-usd-greater-than)
           :cache cache))

(defun get-onchain-top-traders (network-id token-address &key traders sort include-address-label (cache t))
  "GET /onchain/networks/{network_id}/tokens/{token_address}/top_traders
Top traders for a token. Analyst plan and above."
  (api-get (api-path "onchain" "networks" network-id "tokens" token-address "top_traders")
           :query (query "traders" traders "sort" sort "include_address_label" include-address-label)
           :cache cache))

(defun get-onchain-top-holders (network address &key holders include-pnl-details (cache t))
  "GET /onchain/networks/{network}/tokens/{address}/top_holders
Top holders for a token. Analyst plan and above."
  (api-get (api-path "onchain" "networks" network "tokens" address "top_holders")
           :query (query "holders" holders "include_pnl_details" include-pnl-details)
           :cache cache))

(defun get-onchain-holders-chart (network token-address &key days (cache t))
  "GET /onchain/networks/{network}/tokens/{token_address}/holders_chart
Historical holder counts. Analyst plan and above."
  (api-get (api-path "onchain" "networks" network "tokens" token-address "holders_chart")
           :query (query "days" days)
           :cache cache))

(defun get-onchain-categories (&key page sort (cache t))
  "GET /onchain/categories
GeckoTerminal categories. Analyst plan and above."
  (api-get (api-path "onchain" "categories")
           :query (query "page" page "sort" sort)
           :cache cache))

(defun get-onchain-category-pools (category-id &key include page sort (cache t))
  "GET /onchain/categories/{category_id}/pools
Pools in a GeckoTerminal category. Analyst plan and above."
  (api-get (api-path "onchain" "categories" category-id "pools")
           :query (query "include" include "page" page "sort" sort)
           :cache cache))

(defun get-onchain-networks (&key page (cache t))
  "GET /onchain/networks
Supported GeckoTerminal networks."
  (api-get (api-path "onchain" "networks")
           :query (query "page" page)
           :cache cache))

(defun get-onchain-dexes (network &key page (cache t))
  "GET /onchain/networks/{network}/dexes
Supported DEXs on a network."
  (api-get (api-path "onchain" "networks" network "dexes")
           :query (query "page" page)
           :cache cache))

(defun get-onchain-search-pools (&key query network include page (cache t))
  "GET /onchain/search/pools
Search pools by address, token name, symbol, or contract."
  (api-get (api-path "onchain" "search" "pools")
           :query (query "query" query "network" network "include" include "page" page)
           :cache cache))
