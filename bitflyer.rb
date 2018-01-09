require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'dotenv'
require 'active_support/all'
require 'daru'
require 'statsample'
require './slack'

Dotenv.load
NO_ORDER   = "注文：NO ORDER"
BUY_ORDER  = "注文：BUY #{ENV["ORDER_SIZE"]} BTC"
SELL_ORDER = "注文：SELL #{ENV["ORDER_SIZE"]} BTC"

def get_price
  uri = URI.parse("https://api.bitflyer.jp")
  uri.path = '/v1/getboard'
  uri.query = ''

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  response = https.get uri.request_uri
  response_hash = JSON.parse(response.body)
  response_hash["mid_price"]
end

def market_order(side)
  key = ENV["API_KEY"]
  secret = ENV["API_SECRET"]

  timestamp = Time.now.to_i.to_s
  method = "POST"
  uri = URI.parse("https://api.bitflyer.jp")
  uri.path = "/v1/me/sendchildorder"
  body = '{
    "product_code": "BTC_JPY",
    "child_order_type": "MARKET",
    "side": "' + side + '",
    "size": ' + ENV["ORDER_SIZE"] + ',
    "minute_to_expire": 10000,
    "time_in_force": "GTC"
  }'

  text = timestamp + method + uri.request_uri + body
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, text)

  options = Net::HTTP::Post.new(uri.request_uri, initheader = {
    "ACCESS-KEY" => key,
    "ACCESS-TIMESTAMP" => timestamp,
    "ACCESS-SIGN" => sign,
    "Content-Type" => "application/json"
  });
  options.body = body

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  response = https.request(options)
  puts response.body
end

def get_price_history
  now = Time.now
  time_limit_ago = now.since(9.hours).ago(5.hours).to_i

  uri = URI.parse("https://api.cryptowat.ch")
  uri.path = '/markets/bitflyer/btcjpy/ohlc'
  uri.query = {
  	periods: ENV['ORDER_PERIODS'],
  	after: time_limit_ago
  }.to_param

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  response = https.get uri.request_uri
  response_hash = JSON.parse(response.body)
  # [ CloseTime, OpenPrice, HighPrice, LowPrice, ClosePrice, Volume ]
  response_hash["result"]["#{ENV['ORDER_PERIODS']}"]
end

def get_close_price_history(result)
  close_prices = result.map do |item|
    item[4]
  end
end

def order
  result = get_price_history
  last_high_price = result[-1][2]
  last_low_price = result[-1][3]
  close_prices = get_close_price_history(result)
  df = Daru::Vector.new(close_prices)
  # 単純移動平均 sma
  sma = df.mean
  # 標準偏差 standard deviation, SD
  sd = df.std
  sd_100 = sd / 100

  low_limit = sma - sd * 2
  high_limit = sma + sd * 2
  now_price = get_price
  stats = <<~EOS
    ```
    現在価格：    #{now_price}
    移動平均-2σ： #{low_limit}
    移動平均+2σ： #{high_limit}
    最終高値：    #{last_high_price}
    最終安値：    #{last_low_price}
    ```
  EOS
  if now_price < low_limit
  	if now_price < last_low_price - sd_100
  	  market_order('SELL')
  	  post_slack (stats + SELL_ORDER)
    elsif now_price > last_low_price + sd_100
      market_order('BUY')
  	  post_slack (stats + BUY_ORDER)
    end
  elsif now_price > high_limit
  	if now_price > last_high_price + sd_100
      market_order('BUY')
  	  post_slack (stats + BUY_ORDER)
    elsif now_price < last_high_price - sd_100
  	  market_order('SELL')
  	  post_slack (stats + SELL_ORDER)
    end
  end
  
end
