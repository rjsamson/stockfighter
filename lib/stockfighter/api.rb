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

    def block_until_first_trade()
      puts "Waiting until first trade of #{@symbol}.#{@venue}"

      quote = nil
      loop do
        quote = get_quote
        puts quote
        break if quote['last'] != nil
      end
      quote
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

    def block_until_order_filled(order_id)
      puts "Blocking until order #{order_id} is filled"

      loop do 
        quote = get_quote
        order_status = order_status(order_id)
        puts "Order Status: #{order_status['direction']} #{order_status['originalQty']} #{order_status['symbol']}.#{order_status['venue']} @ #{order_status['price']} FilledQuantity:#{order_status['totalFilled']} Last Price: #{quote['last']}"
        break if not order_status["open"]
      end       
    end

    def cancel_order(order_id)
      HTTParty.delete("#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}/orders/#{order_id}", headers: {"X-Starfighter-Authorization" => @api_key})
    end

    def order_status(order_id)
      HTTParty.get("https://api.stockfighter.io/ob/api/venues/#{@venue}/stocks/#{@symbol}/orders/#{order_id}", :headers => {"X-Starfighter-Authorization" => @api_key}).parsed_response
    end

    def order_book
      HTTParty.get("#{BASE_URL}/venues/#{@venue}/stocks/#{@symbol}", {"X-Starfighter-Authorization" => @api_key}).parsed_response
    end

    def venue_up?
      response = HTTParty.get("#{BASE_URL}/venues/#{@venue}/heartbeat", {"X-Starfighter-Authorization" => @api_key}).parsed_response
      response["ok"]
    end

    def status_all
      HTTParty.get("#{BASE_URL}/venues/#{@venue}/accounts/#{@account}/orders", {"X-Starfighter-Authorization" => @api_key})
    end
  end
end
