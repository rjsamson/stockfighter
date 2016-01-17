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

    def start(tickertape_enabled:true, executions_enabled:true)

      EM.epoll
      EM.run do

        EM.error_handler{ |e|
          abort("Error raised during event loop: #{e}")
        }

        if tickertape_enabled
          tickertape_options = {
            :uri => "#{WS_URL}/#{@account}/venues/#{@venue}/tickertape", 
            :ssl => true
          }

          tickertape = WebSocket::EventMachine::Client.connect(tickertape_options)
          tickertape.onopen do
            puts "#{@account} tickertape websocket: connected"
          end

          tickertape.onmessage do |msg|
            incoming = JSON.parse(msg)
            if not incoming["ok"]
              raise "#{@account} tickertape websocket: Error response received: #{msg}"
            end
            if incoming.key?('quote')
              quote = incoming['quote']
              @quote_callbacks.each { |callback|
                  callback.call(quote)
              }
            else
              raise "#{@account} tickertape websocket: TODO: Unhandled message type: #{msg}"
            end
          end

          tickertape.onerror do |e|
            puts "#{@account} tickertape websocket: Error #{e}"
          end

          tickertape.onping do |msg|
            puts "#{@account} tickertape websocket: Received ping: #{msg}"
          end

          tickertape.onpong do |msg|
            puts "#{@account} tickertape websocket: Received pong: #{msg}"
          end

          tickertape.onclose do |code, reason|
            raise "#{@account} tickertape websocket: Client disconnected with status code: #{code} and reason: #{reason}"
          end
        end

        if executions_enabled
          executions_options = {
            :uri => "#{WS_URL}/#{@account}/venues/#{@venue}/executions", 
            :ssl => true
          }

          executions = WebSocket::EventMachine::Client.connect(executions_options)
          executions.onopen do
            puts "#{@account} executions websocket: connected"
          end

          executions.onmessage do |msg|
            execution = JSON.parse(msg)
            if not execution["ok"]
              raise "#{@account} execution websocket: Error response received: #{msg}"
            end
            @execution_callbacks.each { |callback|
              callback.call(execution)
            }
          end

          executions.onerror do |e|
            puts "#{@account} executions websocket: Error: #{e}"
          end

          executions.onping do |msg|
            puts "#{@account} executions websocket: Received ping: #{msg}"
          end

          executions.onpong do |msg|
            puts "#{@account} executions websocket: Received pong: #{msg}"
          end

          executions.onclose do |code, reason|
            puts "#{@account} executions websocket: Client disconnected with status code: #{code} and reason: #{reason}, reconnecting"
            executions = WebSocket::EventMachine::Client.connect(executions_options)
          end
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
