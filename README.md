# cl-coingecko

A Common Lisp client for the [CoinGecko API](https://docs.coingecko.com).

It covers the v3 REST surface — simple prices, coin metadata, historical
charts and OHLC, exchanges, derivatives, treasuries, NFTs, search, global
stats, and the onchain / GeckoTerminal endpoints.  WebSockets and webhooks
are not wrapped.

The high-level helpers are aimed at [limbic.fi](https://limbic.fi): current
quotes and price histories for Bitcoin and friends, including USD, gold
(`xau`), and silver (`xag`).

- Docs: [docs.coingecko.com](https://docs.coingecko.com)
- Github: [cgore/cl-coingecko](https://github.com/cgore/cl-coingecko)

## Install

Clone next to your other local systems (or symlink the `.asd` into
`~/programming/lisp/systems/`):

```
(asdf:load-system :coingecko)
(in-package :coingecko)
```

Depends on `alexandria`, `dexador`, `function-cache`, `quri`, `sigma`, and
`yason`.

## Authentication

Three plans, matching CoinGecko:

| Plan | Host | Header |
| --- | --- | --- |
| Keyless (default) | `https://api.coingecko.com/api/v3` | none |
| Demo | same public host | `x-cg-demo-api-key` |
| Pro | `https://pro-api.coingecko.com/api/v3` | `x-cg-pro-api-key` |

On load the library reads, in order, `COINGECKO_PRO_API_KEY`,
`COINGECKO_DEMO_API_KEY`, then `COINGECKO_API_KEY`.  You can also set it in
the image:

```lisp
(use-demo "your-demo-key")
(use-pro  "your-pro-key")
(use-keyless)
```

Keyless is fine for trying things.  It is rate-limited (~10–30 calls/min)
and not suitable for production polling.  Get a [Demo or Pro
key](https://www.coingecko.com/en/developers/dashboard).

Some endpoints (OHLC range, new listings, news, most onchain filters,
enterprise supply charts) require a paid plan.  The wrappers are still
there; CoinGecko will reject them if your key cannot call them.

## Price histories (the Limbic path)

```lisp
;; Daily-ish Bitcoin prices for the last year, as (universal-time price) pairs.
(price-history :bitcoin :vs-currency :usd :days 365)

;; Same thing by ticker — :btc maps to the CoinGecko id "bitcoin".
(price-history :btc :days 90 :interval :daily)

;; OHLC candles: (universal-time open high low close)
(ohlc-history :bitcoin :days 30)

;; Snapshot at 00:00 UTC on a date.
(history :bitcoin "2024-01-15")
(history :bitcoin '(2024 1 15))

;; Raw CoinGecko payloads if you want market cap and volume series too.
(market-chart :bitcoin :vs-currency :usd :days 30)
(market-chart-range :bitcoin
                    :from (encode-universal-time 0 0 0 1 1 2024 0)
                    :to   (encode-universal-time 0 0 0 1 2 2024 0))
```

`:days` may be an integer or `"max"`.  Auto-granularity is CoinGecko's: 1
day is 5-minute points, 2–90 days are hourly, longer is daily.  Pass
`:interval :daily` (or `:hourly`) to override.

## Current quotes

```lisp
(price :bitcoin :usd)
(price :eth :usd)

(btc/usd)
(eth/usd)
(xag/usd)   ; silver, troy ounce
(xau/usd)   ; gold, troy ounce
(btc/xag)
(eth/xau)
```

These go through one cached `/simple/price` call for bitcoin and ethereum
versus `usd`, `xag`, and `xau`.

## The rest of the API

Every documented REST path has a `get-*` function in `coingecko/rest-api`
(re-exported from `coingecko`).  Keyword arguments are the query
parameters with underscores turned into hyphens.  Lists become
comma-separated.  `t` / `:true` / `:false` become JSON booleans.  Results
are `yason` hash-tables (arrays as vectors).

```lisp
(ping)
(get-simple-price :ids '(:btc :eth) :vs-currencies '(:usd :eur)
                  :include-24hr-change t)
(get-coins-markets :vs-currency :usd :per-page 10)
(get-coin :bitcoin :tickers nil :market-data t)
(get-trending)
(get-global)
(get-onchain-trending-pools :duration :h24)
```

Pass `:cache nil` to skip the 60-second `function-cache` layer.  `/key`
defaults to uncached.

See `coingecko.restclient` for curl-style examples of the same paths.

## Testing

Specs are `sigma/behave` `behavior` / `should` forms, same style as
[sigma](https://github.com/cgore/sigma).  Pure helpers run at load time.
`asdf:test-system` reloads the sources so those assertions run again.

```lisp
(asdf:test-system :coingecko)
```

To also hit the live API (ping, a Bitcoin price, a one-day history):

```
COINGECKO_LIVE_TESTS=1
```

then `asdf:test-system` again.  A Demo key in the environment is enough;
keyless works if you have not already exhausted the public rate limit.

## License

Copyright (c) 2023 -- 2026, Christopher Mark Gore,
Soli Deo Gloria,
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Christopher Mark Gore nor the names of other contributors may be used to endorse or promote products derived from this software without specific prior written permission.

**THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS *"AS IS"* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.**
