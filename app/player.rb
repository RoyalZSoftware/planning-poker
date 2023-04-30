module Poker
	class Player
		attr_reader :id
		attr_reader :username
		attr_reader :bid
		attr_accessor :current_game

		def initialize(username)
			@id = SecureRandom.hex
			@username = username
			@current_game = nil
			@bid = Bid.new(1)
		end

		def bid=(bid)
		raise "Not ingame" if @current_game == nil
			@bid = bid
		end
	end
end
