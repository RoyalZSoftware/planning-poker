module Web
	class Context
		attr_accessor :players, :games, :web_sockets
		def initialize
			@players = {}
			@games = []
			@web_sockets = []
		end

		def create_game_in_behalf_of(player)
			game = Poker::Game.new
			game.add_player player
			@games << game
			@games.length - 1
		end

		def find_game(id)
			@games[id]
		end
	end
end
