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
		end

		def handle_stats
			data = {
				current_game: {
					users: @player&.current_game&.players&.map(&:username),
					state: @player&.current_game&.state,
				},
				username: @player&.username,
			}
			@ws.send(JSON.dump(data))
		end

		def handle_flip
			raise "Not registered yet" if @player.nil?
			game = @player.current_game
			game.flip
			raise "Game not found. Create or join first" if game.nil?

			@context.web_sockets.each do |wss|
				wss.send(JSON.dump(game.results))
			end
			nil
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

		# create
		def handle_create_game
			game = @context.create_game_in_behalf_of(@player)
			@ws.send(JSON.dump(game))
		end

		def set_player
			@player = @context.players[@ws]
		end
	end
end
