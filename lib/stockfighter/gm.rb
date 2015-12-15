require 'httparty'

module Stockfighter
  class GM
    GM_URL = "https://www.stockfighter.io/gm"

    attr_accessor :instance_id

    def initialize(key:, level:)
      @api_key = key
      @level = level

# , :debug_output => $stdout
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
        update_config(resp)
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
      response = get_instance()
      response["done"] && response["ok"]
    end

    def block_until_instance_state(expected_state)
      loop do
        current_state = get_instance()['state']
        puts "Waiting for game instance to change - expected_state: #{expected_state}, current_state: #{current_state}"
        break if current_state == expected_state
      end
    end

    def get_instance
      response = HTTParty.get("#{GM_URL}/instances/#{@instance_id}", :headers => {"X-Starfighter-Authorization" => @api_key})
      if response.code != 200
        raise "HTTP error response received from #{GM_URL}: #{response.code}"
      end
      if not response["ok"]
        raise "Error response received from #{GM_URL}: #{response['error']}"
      end

      if response.key?('flash')
        if response['flash'].key?('success')
          puts "\e[#32m#{response['flash']['success']}\e[0m"
        else
          raise "TODO: Unhandled flash scenario: #{response}"
        end
      end

      response
    end

    def update_config(resp)

      if resp.key?('instructions')
        if resp['instructions'].key?('Instructions')
          puts "\e[#34m#{resp['instructions']['Instructions']}\e[0m"
        else
          raise "TODO: Unhandled instructions scenario: #{resp}"
        end
      end

      if resp.code == 200
        if resp["ok"]
          @config = {}
          @config[:key] = @api_key
          @config[:account] = resp["account"]
          @config[:venue] = resp["venues"][0]
          @config[:symbol] = resp["tickers"][0]

          @instance_id = resp["instanceId"]
        else
          raise "Error response received from #{GM_URL}: #{resp['error']}"
        end
      else
        raise "HTTP error response received from #{GM_URL}: #{resp.code}"
      end
    end
    private :update_config
  end
end
