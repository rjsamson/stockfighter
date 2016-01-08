require 'httparty'

module Stockfighter
  class Api
    BASE_URL = "https://api.stockfighter.io/ob/api"

    def initialize(key:, account:, symbol:, venue:)
      @api_key = key
      @account = account
      @symbol = symbol
      @venue = venue
    end

    def get_quote
      perform_request("get", "#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/quote")
    end

    def place_order(price:, quantity:, direction:, order_type:)
      order = {
        "account" => @account,
        "venue" => @venue,
        "symbol" => @symbol,
        "price" => price,
        "qty" => quantity,
        "direction" => direction,
        "orderType" => order_type
      }
      perform_request("post", "#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/orders", body: JSON.dump(order))
    end

    def cancel_order(order_id)
      perform_request("delete", "#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/orders/#{order_id}")
    end

    def order_status(order_id)
      perform_request("get", "#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/orders/#{order_id}")
    end

    def order_book
      perform_request("get", "#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}")
    end

    def venue_up?
      response = perform_request("get", "#{BASE_URL}/venues/#{@venue}/heartbeat")
      response["ok"]
    end

    def status_all
      perform_request("get", "#{BASE_URL}/venues/#{@venue}/accounts/#{@account}/orders")
    end

    def perform_request(action, url, body:nil)
      options = {
        :headers => {"X-Starfighter-Authorization" => @api_key},
        :format => :json
      }
      if body != nil
        options[:body] = body
      end
      response = HTTParty.method(action).call(url, options)

      if response.code == 200 and response["ok"]
        response
      elsif not response["ok"]
        raise "Error response received from #{url}: #{response['error']}"
      else
        raise "HTTP error response received from #{url}: #{response.code}"
      end
    end

    private :perform_request
  end
end
