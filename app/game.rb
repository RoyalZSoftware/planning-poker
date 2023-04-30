module Poker
	class Game
		attr_reader :id, :players, :state, :prompt, :changed

		def initialize(prompt = 'Set a card')
			@id = SecureRandom.hex
			@players = []
			@state = :picking
			@prompt = prompt
			@changed = Subject.new
		end

		def add_player(player)
			@players << player
			player.current_game = self
			notify_observers
		end

		def remove_player(player)
			@players.delete(player)
			notify_observers
		end

		def flip
			@state = :results
			notify_observers
		end
		
		def prompt=(prompt)
			@prompt = prompt
			@state = :picking
			notify_observers
		end
		
		def results
			raise "Still ingame" if @state == :picking
			@players.map(&:bid)
			@players.map do |player|
				{name: player.username, value: player.bid&.value}
			end
		end

		protected

		def notify_observers
			@changed.next(self)
		end
	end
end
