# Stockfighter

A gem for interacting with the [Stockfighter.io](https://www.stockfighter.io) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stockfighter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stockfighter

## Features

This gem can be used as a simple API client for the trading API, but also
includes more advanced features for interacting with the (officially undocumented)
GM API. This includes the ability to start / stop / restart / resume levels,
automatically fetch level info such as ticker, venue, and account, and also poll
the GM server regularly and return level and game information.

Support for the websockets API is also available

## Usage

Coming soon: comprehensive overview and API overview! For now, take a look at
some of the sample code below.

### Example
```ruby
require 'stockfighter'

# Use the GM to fetch level info for the trading API automatically

gm = Stockfighter::GM.new(key: "supersecretapikey1234567", level: "first_steps")

api = Stockfighter::Api.new(gm.config)

# Use the GM to register message callbacks for messages received from the GM. The GM needs to be initialized with polling: true to set up polling of the GM and enable callbacks.

gm = Stockfighter::GM.new(key: "supersecretapikey1234567", level: "first_steps", polling: true)

ansi_code = Hash.new
ansi_code['success'] = "\e[#32m"
ansi_code['info']    = "\e[#34m"
ansi_code['warning'] = "\e[#33m"
ansi_code['error']   = "\e[#31m"
ansi_code['danger']  = "\e[#31m"

gm.add_message_callback { |type,message|
	abort("Unhandled message type #{type}") unless ansi_code.key?(type)
	puts "#{ansi_code[type]}#{message}\e[0m"
}

gm.add_state_change_callback { |previous_state, new_state|
	if new_state == 'won'
		puts "You've won!"
	end
}

# Restart the level

gm.restart

# Resume the level

gm.resume

# Stop the level

gm.stop

# Check if the level is active

gm.active?

# Print the order book
puts api.order_book

# Check if the venue is up
puts api.venue_up?

# Print a quote
puts api.get_quote

# Print the whole order book
puts api.order_book

# Place an order
order = api.place_order(price: 4250, quantity: 100, direction: "buy", order_type: "limit")

# Check the status of an order
order_id = order["id"]
order_status = api.order_status(order_id)
puts order_status["open"]
puts order_status["fills"]
puts order_status["totalFilled"]

# Cancel an order
cancellation = api.cancel_order(order_id)
puts cancellation["totalFilled"]

# Print the status of all your orders for the stock on the venue
puts api.status_all

# API can also be initialized manually

key = "supersecretapikey1234567"
account = "ACT123456789"
symbol = "ABC"
venue = "DEFGHEX"

api = Stockfighter::Api.new(key: key, account: account, symbol: symbol, venue: venue)

```

# Websockets api example

```ruby
websockets = Stockfighter::Websockets.new(gm.config)
websockets.add_quote_callback { |quote|
	# Ensure you don't have long running operations (eg calling api.*) as part of this 
	# callback method as the event processing for all websockets is performed on 1 thread. 
	puts quote
}

websockets.add_execution_callback { |execution|
	# Ensure you don't have long running operations (eg calling api.*) as part of this 
	# callback method as the event processing for all websockets is performed on 1 thread. 
	puts execution
}

websockets.start()
```

## Todo

* ~~TODO: Usage instructions!~~
* ~~TODO: Game master integration~~
* TODO: Tests!
* TODO: Error Handling (partially complete)

## Contributing

1. Fork it ( https://github.com/rjsamson/stockfighter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Write some tests
6. Run all the tests using the following command:
	`API_KEY="insert_your_api_key_here" rake test`
7. Create a new Pull Request
