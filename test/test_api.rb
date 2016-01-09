require 'minitest/autorun'
require 'stockfighter'

class ApiTest < Minitest::Unit::TestCase
	def test_get_quote
		api = get_api()

		quote = api.get_quote()
		assert_equal 'FOOBAR', quote['symbol']
		assert_equal 'TESTEX', quote['venue']
		assert quote.key?('quoteTime')
	end

	def test_place_order_invalid_scenarios
		api = get_api()

		assert_raises(RuntimeError) {
			api.place_order(price:10000000, quantity:100, direction:'invalid_direction', order_type:'limit')
		}
		assert_raises(RuntimeError) {
			api.place_order(price:10000000, quantity:100, direction:'buy', order_type:'invalid_order_type')
		}
		assert_raises(RuntimeError) {
			api.place_order(price:-1, quantity:100, direction:'buy', order_type:'limit')
		}
		assert_raises(RuntimeError) {
			api.place_order(price:10000000, quantity:-1, direction:'buy', order_type:'limit')
		}
	end

	def test_place_order_happy_day
		api = get_api()

		order = api.place_order(price:10, quantity:100, direction:'sell', order_type:'limit')
		assert_equal 'FOOBAR', order['symbol']
		assert_equal 'TESTEX', order['venue']
		assert_equal 'sell', order['direction']
		assert_equal 10, order['price']
		assert_equal 'limit', order['orderType']
		assert_equal 'EXB123456', order['account']

		assert order.key?('ts')
		assert order.key?('fills')
	end

	def test_cancel_order_invalid_scenarios
		api = get_api()

		assert_raises(RuntimeError) {
			api.cancel_order(1)
		}
	end

	def test_cancel_order_happy_day
		api = get_api()

		order = api.place_order(price:1, quantity:1000000, direction:'buy', order_type:'limit')
		assert order['open']

		cancel_response = api.cancel_order(order['id'])
		assert !cancel_response['open']
	end

	def get_api
		api_key = ENV['API_KEY']
		assert api_key.to_s != '', "export API_KEY='secret' before running these tests, where 'secret' is your API key"

		config = {
			:key => api_key,
			:account => 'EXB123456',
			:venue => 'TESTEX',
			:symbol => 'FOOBAR',
		}
		Stockfighter::Api.new(config)
	end
end