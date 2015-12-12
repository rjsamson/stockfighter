require 'httparty'

module Stockfighter
  class GM
    GM_URL = "https://www.stockfighter.io/gm"

    attr_accessor :instance_id

    def initialize(key:, level:)
      @api_key = key
      @level = level

      resp = HTTParty.post("#{GM_URL}/levels/#{level}", :headers => {"X-Starfighter-Authorization" => @api_key})

      update_config(resp)
    end

    def config
      if @config[:account] && @config[:venue] && @config[:symbol]
        @config
      else
        nil
      end
    end

    def restart
      if @instance_id
        resp = HTTParty.post("#{GM_URL}/instances/#{@instance_id}/restart", :headers => {"X-Starfighter-Authorization" => @api_key})
        udpate_config(resp)
      end
    end

    def stop
      if @instance_id
        resp = HTTParty.post("#{GM_URL}/instances/#{@instance_id}/stop", :headers => {"X-Starfighter-Authorization" => @api_key})
        update_config(resp)
      end
    end

    def resume
      if @instance_id
        resp = HTTParty.post("#{GM_URL}/instances/#{@instance_id}/resume", :headers => {"X-Starfighter-Authorization" => @api_key})
        update_config(resp)
      end
    end

    def active?
      response = HTTParty.get("#{GM_URL}/instances/#{@instance_id}", :headers => {"X-Starfighter-Authorization" => @api_key})
      response["done"] && response["ok"]
    end
  end

  def update_config(resp)
    @config = {}
    @config[:key] = @api_key
    @config[:account] = resp["account"]
    @config[:venue] = resp["venues"][0]
    @config[:symbol] = resp["tickers"][0]

    @instance_id = resp["instanceId"]
  end
  private :update_config
end