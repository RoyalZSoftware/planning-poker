module Poker
class Bid
	attr_reader :value

	def initialize(value)
		allowed_values = [0, 1, 2, 3, 5, 8, 13, 20]
		raise "Invalid value" unless allowed_values.include? value.to_i
		@value = value
	end
end
end
