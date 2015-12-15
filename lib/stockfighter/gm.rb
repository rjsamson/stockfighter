require 'httparty'

module Stockfighter
  class GM
    GM_URL = "https://www.stockfighter.io/gm"

    attr_accessor :instance_id

    def initialize(key:, level:)
      @api_key = key
      @level = level

      perform_request("post", "#{GM_URL}/levels/#{level}")
    end

    def config
      if @config[:account] && @config[:venue] && @config[:symbol]
        @config
      else
        nil
      end
    end

    def restart
      perform_request("post", "#{GM_URL}/instances/#{@instance_id}/restart")
    end

    def stop
      perform_request("post", "#{GM_URL}/instances/#{@instance_id}/stop")
    end

    def resume
      perform_request("post", "#{GM_URL}/instances/#{@instance_id}/resume")
    end

    def active?
      response = get_instance()
      response["done"] && response["ok"]
    end

    def get_instance
      perform_request("get", "#{GM_URL}/instances/#{@instance_id}")
    end

    def block_until_instance_state(expected_state)
      loop do
        current_state = get_instance()['state']
        puts "Waiting for game instance to change - expected_state: #{expected_state}, current_state: #{current_state}"
        break if current_state == expected_state
      end
    end

    def perform_request(action, url)
      response = HTTParty.method(action).call(url, :headers => {"X-Starfighter-Authorization" => @api_key})
      if response.code != 200
        raise "HTTP error response received from #{url}: #{response.code}"
      end
      if not response["ok"]
        raise "Error response received from #{url}: #{response['error']}"
      end

      if response.key?('flash')
        if response['flash'].key?('success')
          puts "\e[#32m#{response['flash']['success']}\e[0m"
        else
          raise "TODO: Unhandled flash scenario: #{response}"
        end
      end
      if response.key?('instructions')
        if response['instructions'].key?('Instructions')
          puts "\e[#34m#{response['instructions']['Instructions']}\e[0m"
        else
          raise "TODO: Unhandled instructions scenario: #{response}"
        end
      end

      if action == 'post'
        @config = {}
        @config[:key] = @api_key
        @config[:account] = response["account"]
        @config[:venue] = response["venues"][0]
        @config[:symbol] = response["tickers"][0]

        @instance_id = response["instanceId"]        
      end

      response
    end
 
    private :perform_request
  end
end
