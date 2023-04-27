module Poker
	class Game
		attr_reader :players
		attr_reader :state
		attr_reader :prompt

		def initialize(prompt = 'Set a card')
			@players = []
			@state = :picking
			@prompt = prompt
		end

		def add_player(player)
			@players << player
			player.current_game = self
		end

		def remove_player(player)
			@players.delete(player)
		end

		def flip
			@state = :results
		end
		
		def prompt=(prompt)
			@prompt = prompt
			@state = :picking
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
