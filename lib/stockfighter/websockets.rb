require 'httparty'
require 'websocket-eventmachine-client'

module Stockfighter
  class Websockets

    WS_URL = "https://www.stockfighter.io/ob/api/ws"

    def initialize(key:, account:, symbol:, venue:)
      @account = account
      @venue = venue
      @quote_callbacks = []
      @execution_callbacks = []
    end

    def start() 

      EM.epoll
      EM.run do

        EM.error_handler{ |e|
          abort("Error raised during event loop: #{e}")
        }

        tickertape = WebSocket::EventMachine::Client.connect(:uri => "#{WS_URL}/#{@account}/venues/#{@venue}/tickertape", :ssl => true)
        tickertape.onopen do
          puts "tickertape websocket: connected"
        end

        tickertape.onmessage do |msg|
          incoming = JSON.parse(msg)
          if not incoming["ok"]
            raise "tickertape websocket: Error response received: #{msg}"
          end
          if incoming.key?('quote')
            quote = incoming['quote']
            @quote_callbacks.each { |callback|
                callback.call(quote)
            }
          else
            raise "tickertape websocket: TODO: Unhandled message type: #{msg}"
          end
        end

        tickertape.onerror do |e|
          puts "tickertape websocket: Error #{e}"
        end

        tickertape.onping do |msg|
          puts "tickertape websocket: Received ping: #{msg}"
        end

        tickertape.onpong do |msg|
          puts "tickertape websocket: Received pong: #{msg}"
        end

        tickertape.onclose do |code, reason|
          raise "tickertape websocket: Client disconnected with status code: #{code} and reason: #{reason}"
        end

        executions = WebSocket::EventMachine::Client.connect(:uri => "#{WS_URL}/#{@account}/venues/#{@venue}/executions", :ssl => true)
        executions.onopen do
          puts "executions websocket: connected"
        end

        executions.onmessage do |msg|
          execution = JSON.parse(msg)
          if not execution["ok"]
            raise "execution websocket: Error response received: #{msg}"
          end
          @execution_callbacks.each { |callback|
            callback.call(execution)
          }
        end

        executions.onerror do |e|
          puts "executions websocket: Error: #{e}"
        end

        executions.onping do |msg|
          puts "executions websocket: Received ping: #{msg}"
        end

        executions.onpong do |msg|
          puts "executions websocket: Received pong: #{msg}"
        end

        executions.onclose do |code, reason|
          raise "executions websocket: Client disconnected with status code: #{code} and reason: #{reason}"
        end
      end
    end

    def add_quote_callback(&block)
      @quote_callbacks << block
    end

    def add_execution_callback(&block)
      @execution_callbacks << block
    end
  end
end
