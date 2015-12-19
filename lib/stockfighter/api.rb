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
      HTTParty.get("#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/quote", {"X-Starfighter-Authorization" => @api_key}).parsed_response
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

      HTTParty.post("#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/orders", body: JSON.dump(order),
      headers: {"X-Starfighter-Authorization" => @api_key}).parsed_response
    end

    def cancel_order(order_id)
      HTTParty.delete("#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/orders/#{order_id}", headers: {"X-Starfighter-Authorization" => @api_key})
    end

    def order_status(order_id)
      HTTParty.get("#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/orders/#{order_id}", :headers => {"X-Starfighter-Authorization" => @api_key}).parsed_response
    end

    def order_book
      HTTParty.get("#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}", headers: {"X-Starfighter-Authorization" => @api_key}).parsed_response
    end

    def venue_up?
      response = HTTParty.get("#{BASE_URL}/venues/#{@venue}/heartbeat", headers: {"X-Starfighter-Authorization" => @api_key}).parsed_response
      response["ok"]
    end

    def status_all
      HTTParty.get("#{BASE_URL}/venues/#{@venue}/accounts/#{@account}/orders", headers: {"X-Starfighter-Authorization" => @api_key})
    end
  end
end
