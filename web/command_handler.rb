require 'json'

module Web
	class CommandHandler
		def initialize(msg, context, ws)
			@msg = msg
			@context = context
			@ws = ws
		end

		def self.handle(msg, context, ws)
			command_handler = CommandHandler.new(msg, context, ws)
			command_handler.handle
		end

		def handle
			begin
				result = execute_command
			rescue => ex
				@ws.send(JSON.dump(ex))
			end
		end

		private

		def execute_command
			@player = set_player
			return handle_register if @msg.start_with? 'register;'
			return handle_join if @msg.start_with? 'join;'
			return handle_stats if @msg == 'stats'
			return handle_flip if @msg == 'flip'
			return handle_bid if @msg.start_with? 'bid;'
			return handle_create_game if @msg == 'create'
			return handle_set_prompt if @msg.start_with? 'set_prompt'
		end

		def handle_stats
			data = {
				current_game: {
					id: @context.games.find_index(@player&.current_game).to_i,
					users: @player&.current_game&.players&.map(&:username),
					state: @player&.current_game&.state,
					prompt: @player&.current_game&.prompt
				},
				username: @player&.username,
				type: 'stats'
			}
			@ws.send(JSON.dump(data))
		end

		# flip
		def handle_flip
			raise "Not registered yet" if @player.nil?
			game = @player.current_game
			raise "Game not found. Create or join first" if game.nil?
			game.flip

			send_message_to_players_of_same_game_as_this_player({data: game.results, type: 'results'})
		end

		# bid;value
		def handle_bid
			raise "Not registered yet" if @player.nil?
			value = @msg.split(';')[1]
			@player.bid = Poker::Bid.new(value.to_i)
		end

		# register;username
		def handle_register
			@context.players[@ws] = Poker::Player.new(@msg.split(';')[1])
		end

		# join;game_id
		def handle_join
			raise "Not registered yet" if @player.nil?
			game_id = @msg.split(';')[1]
			game = @context.find_game(game_id.to_i)
			raise "Game not found. Create first" if game.nil?
			
			game.add_player @player
			"OK"
		end

		# prompt
		def handle_set_prompt
			set_player
			raise "Not registered yet" if @player.nil?
			raise "Game not found. Create first" if @player.current_game.nil?
			prompt = @msg.split(';')[1]
			@player.current_game.prompt = prompt
			@player.current_game.reset
			
			send_message_to_players_of_same_game_as_this_player("new_prompt;#{prompt}")
		end

		# create
		def handle_create_game
			game = @context.create_game_in_behalf_of(@player)
			@ws.send(JSON.dump(game))
		end

		def set_player
			@player = @context.players[@ws]
		end

		def send_message_to_players_of_same_game_as_this_player(msg)
			@context.web_sockets.each do |websocket|
				player = @context.players[websocket]
				continue if player.nil?
				
				continue if player.current_game != @player.current_game
				
			  websocket.send(JSON.dump(msg))
			end
		end
	end
end
