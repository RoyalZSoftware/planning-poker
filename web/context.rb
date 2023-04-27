module Web
	class Context
		attr_accessor :players, :games, :web_sockets

		def initialize
			@players = []
			@games = []
			@web_sockets = []
		end

		def make_game
            game = ObservableGame.new(@context)

			game.player_added.subscribe do |values|
				player = values[0]
				send_message_to_game_members({
					type: 'player_joined',
					username: player.username
				}, game)
			end
			game.player_removed.subscribe do |values|
				player = values[0]
				send_message_to_game_members({
					type: 'player_left',
					username: player.username,
				}, game)
			end
			game.prompt_changed.subscribe do |values|
				prompt = values[0]
				send_message_to_game_members({
					type: 'prompt_changed',
					prompt: prompt
				}, game)
			end
			game.state_changed.subscribe do |values|
				state = values[0]
				send_message_to_game_members({
					type: 'state_changed',
					state: state
				}, game)
			end
            @games.push game

			game
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
