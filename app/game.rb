module Poker
	class Game
		attr_reader :players
		attr_reader :state

		def initialize
			@players = []
			@state = :picking
		end

		def add_player(player)
			@players << player
			player.current_game = self
		end

		def flip
			@state = :results
		end
		
		def reset
			@state = :picking if @state == :results
		end
		
		def results
			raise "Still ingame" if @state == :picking
			@players.map(&:bid)
			@players.map do |player|
				{name: player.username, value: player.bid&.value}
			end
		end
	end
end
