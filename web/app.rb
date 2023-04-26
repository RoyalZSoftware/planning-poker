require_relative '../app/poker'
require_relative './ws_handler'
require_relative './command_handler'
require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

context = Web::Context.new

get '/' do
	unless request.websocket?
		erb :index
	else
		request.websocket do |ws|
			ws.onopen do
				context.sockets << ws
			end
			ws.onmessage do |msg|
				CommandHandler.handle(msg, context, ws)
			end
			ws.onclose do
				context.sockets.delete(ws)
			end
		end
	end
end

