module Web
	class Context
		attr_accessor :players, :games, :web_sockets

		def initialize
			@players = []
			@games = []
			@web_sockets = []
		end

		def add_game(game)
			game.changed.subscribe do |values|
				player = values[0]
				send_message_to_game_members({type: 'game_changed'}, game)
			end
            @games << game
		end

		def find_player_by_id(id)
			@players.find {|item| item.id == id}
		end

		def find_player_by_web_socket(ws)
			@players.find {|x| x.web_socket == ws}
		end
		
		def register_player(player)
			@players << player
		end

		def remove_player_by_ws(ws)
			@web_sockets.delete(ws)
			player = find_player_by_web_socket(ws)
			return if player.nil?

			@players.delete(player)
			@games.each do |game|
				game.remove_player(player)
			end
		end

		def find_game_by_id(game_id)
			@games.find {|game| game.id == game_id}
		end

		private

		def send_message_to_game_members(msg, game)
			web_sockets.each do |websocket|
				websocket.send(JSON.dump(msg))
			end
		end
	end
end
