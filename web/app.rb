require_relative '../app/poker'
require_relative './ws_handler'
require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

player_sockets = {}
current_game = Poker::Game.new

get '/' do
	unless request.websocket?
		erb :index
	else
		request.websocket do |ws|
			ws.onopen do
				settings.sockets << ws
				puts ws.inspect
			end
			ws.onmessage do |msg|
				if msg.start_with? 'register;'
					player_sockets[ws] = Poker::Player.new(msg.split(';')[1])
					current_game.add_player player_sockets[ws]
				end
				if msg.start_with? 'play;'
					player = player_sockets[ws]
					bid = msg.split(';')[1].to_i
					begin
						bid = Poker::Bid.new(bid)
						player.bid = bid
						ws.send(JSON.dump(bid.value))
					rescue => ex
						ws.send(ex)
					end
				end
				if msg == 'flip'
					current_game.flip
					settings.sockets.each do |wss|
						wss.send(JSON.dump(current_game.results))
					end
				end
			end
			ws.onclose do
				settings.sockets.delete(ws)
			end
		end
	end
end

