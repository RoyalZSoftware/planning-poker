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

		def execute_command
			return handle_register if @msg.start_with? 'register;'
		end

		private
		
		# register;player_id
		def handle_register
			player_id = @msg.split(';')[1]
			player = @context.find_player_by_id(player_id)
			player.web_socket = @ws
		end

		# join;game_id
		def handle_join
			raise "Not registered yet" if @player.nil?
			game_id = @msg.split(';')[1]
			game = @context.find_game(game_id.to_i)
			raise "Game not found. Create first" if game.nil?
			
			game.add_player @player
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
			game = Web::Game.new
			game = @context.create_game_in_behalf_of(@player)
			@ws.send(JSON.dump(game))
		end

		def set_player
			@player = @context.players[@ws]
		end

	end
end
