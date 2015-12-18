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

## Usage

### Example
```ruby
require 'stockfighter'

# Use the GM to fetch the info automatically

gm = Stockfighter::GM.new(key: "supersecretapikey1234567", level: "first_steps", polling:true)

# Register message callbacks - GM needs to be constructed with polling:true for these callbacks to work
gm.add_message_callback('success') { |message|
	puts "\e[#32m#{message}\e[0m"
}
gm.add_message_callback('info') { |message|
	puts "\e[#34m#{message}\e[0m"
}
gm.add_state_change_callback { |previous_state, new_state|
	if new_state == 'won'
		puts "You've won!"
	end
}

# Register message callbacks 
gm.add_message_callback('success') { |message|
	puts "\e[#32m#{message}\e[0m"
}
gm.add_message_callback('info') { |message|
	puts "\e[#34m#{message}\e[0m"
}

api = Stockfighter::Api.new(gm.config)

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

## Todo

* ~~TODO: Usage instructions!~~
* ~~TODO: Game master integration~~
* TODO: Tests
* TODO: Error Handling

## Contributing

1. Fork it ( https://github.com/rjsamson/stockfighter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
