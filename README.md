# Stockfighter

A gem for interacting with the Stockfighter.io API.

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

gm = Stockfighter::GM.new("supersecretapikey1234567")
first_steps_config = gm.config_for(level: "first_steps")

api = Stockfighter::Api.new(first_steps_config)

# Or initialize manually

key = "supersecretapikey1234567"
account = "ACT123456789"
symbol = "ABC"
venue = "DEFGHEX"

api = Stockfighter::Api.new(key: key, account: account, symbol: symbol, venue: venue)

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

```

## Todo

* ~~TODO: Usage instructions!~~
* ~~TODO: Game master integration~~
* TODO: Tests

## Contributing

1. Fork it ( https://github.com/rjsamson/stockfighter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
