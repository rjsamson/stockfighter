require 'httparty'

module Stockfighter
  class GM
    def initialize(key)
      @api_key = key
    end

    def config_for(level:)
      resp = HTTParty.post("https://www.stockfighter.io/gm/levels/#{level}", :headers => {"X-Starfighter-Authorization" => @api_key})

      config = {}
      config[:account] = resp["account"]
      config[:venue] = resp["venues"][0]
      config[:symbol] = resp["tickers"][0]
      config[:key] = @api_key

      if config[:account] && config[:venue] && config[:symbol]
        config
      else
        nil
      end
    end
  end
end
