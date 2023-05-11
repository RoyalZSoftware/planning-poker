require 'securerandom'

module Poker
	class Player
		attr_reader :id, :username
		attr_accessor :current_game

		def initialize(username)
			@id = SecureRandom.hex
			@username = username
		end

		def bid=(value)
			raise "Not ingame" if @current_game.nil?
			@current_game.set_bid_for(self, value)
		end

		def ==(other)
			other&.id == @id
		end

		def join(game)
			@current_game = game
			@current_game.add_player(self)
		end
	end
end
