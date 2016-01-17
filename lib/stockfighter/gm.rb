require 'httparty'
require 'rufus-scheduler'

module Stockfighter
  class GM
    GM_URL = "https://www.stockfighter.io/gm"

    attr_accessor :instance_id

    def initialize(key:, level:, polling:false)
      @api_key = key
      @level = level

      @message_callbacks = []
      @state_change_callbacks = []
      @trading_day_callbacks = []

      new_level_response = perform_request("post", "#{GM_URL}/levels/#{level}")
      previous_state = new_level_response['state']
      previous_trading_day = 0

      if polling
        # websocket API functionality instead of polling would be great here
        scheduler = Rufus::Scheduler.new(:overlap => false)
        scheduler.every '10s' do
          response = get_instance()

          current_state = response['state']
          if previous_state != current_state
            @state_change_callbacks.each { |callback|
              callback.call(previous_state, current_state)
            }
            previous_state = current_state
          end

          if response.key?('details')
            details = response['details']
            current_trading_day = details['tradingDay']
            end_of_the_world_day = details['endOfTheWorldDay']
            if previous_trading_day != current_trading_day
              @trading_day_callbacks.each { |callback|
                callback.call(previous_trading_day, current_trading_day, end_of_the_world_day)
              }
              previous_trading_day = current_trading_day
            end
          end
        end
      end
    end

    def add_message_callback(&block)
      @message_callbacks << block
    end

    def add_state_change_callback(&block)
      @state_change_callbacks << block
    end

    def add_trading_day_callback(&block)
      @trading_day_callbacks << block
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

    def judge(account:, explanation_link:, executive_summary:)
      evidence = {
        "account" => account,
        "explanation_link" => explanation_link,
        "executive_summary" => executive_summary
      }
      perform_request("post",  "#{GM_URL}/instances/#{@instance_id}/judge", body: JSON.dump(evidence))
    end

    def active?
      response = get_instance()
      response["done"]
    end

    def get_instance
      perform_request("get", "#{GM_URL}/instances/#{@instance_id}")
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
      if response.code != 200
        raise "HTTP error response received from #{url}: #{response.code}"
      end
      if not response["ok"]
        raise "Error response received from #{url}: #{response['error']}"
      end

      if response.key?('flash')
        flash = response['flash']
        flash.each { |type,message|
          @message_callbacks.each { |callback|
            callback.call(type, message)
          }
        }
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
        if response.key?('venues')
          @config[:venue] = response["venues"][0]
        end
        if response.key?('tickers')
          @config[:symbol] = response["tickers"][0]
        end
        @instance_id = response["instanceId"]        
      end

      response
    end
 
    private :perform_request
  end
end
