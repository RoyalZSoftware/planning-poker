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

		def set_player
			@player = @context.players[@ws]
		end

	end
end
