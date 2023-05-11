require_relative './subject'

module Poker
	module BidSystems
		REVERSE_FIB=[0, 0.5, 1, 2, 3, 5, 8, 13, 20]
	end
	class Game
		attr_reader :id, :players, :state, :prompt, :changed, :allowed_bids

		def initialize(prompt = 'Set a card', allowed_bids=BidSystems::REVERSE_FIB)
			@id = SecureRandom.hex
			@players = []
			@state = :picking
			@prompt = prompt
			@allowed_bids = allowed_bids
			@changed = Subject.new
			@player_bids = {}
		end
		
		def set_bid_for(player, bid)
			raise "Not in this game" unless @players.include? player
			raise "Invalid value" unless @allowed_bids.include? bid.to_i

			@player_bids[player] = Bid.new(bid)
			notify_observers
		end

		def add_player(player)
			@players << player
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
		
		def results(cur_player=nil)
			@player_bids.map do |player, bid|
				if player == cur_player
					{name: player.username, value: bid&.value}
				else
					{name: player.username, value: @state == :results ? bid&.value: nil}
				end
			end
		end
		
		protected

		def notify_observers
			@changed.next(self)
		end
	end
end
