require 'json'

module Web
	class CommandHandler
		def initialize(msg, context, ws)
			@msg = msg
			@context = context
			@ws = ws
		end

		def handle
			begin
				handle_register if @msg.start_with? 'register;'
				handle_ping if @msg == 'ping'
			rescue => ex
				@ws.send(JSON.dump(ex))
			end
		end

		private
		
		# register;player_id
		def handle_register
			player_id = @msg.split(';')[1]
			player = @context.find_player_by_id(player_id)
			player.web_socket = @ws
		end

		def handle_ping
			@ws.send('pong')
		end
	end
end
