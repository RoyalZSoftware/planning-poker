require_relative '../app/poker'
require_relative './context'
require_relative './command_handler'
require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []
set :port, 80

context = Web::Context.new

get '/' do
	unless request.websocket?
		erb :index
	else
		request.websocket do |ws|
			ws.onopen do
				context.web_sockets << ws
			end
			ws.onmessage do |msg|
				Web::CommandHandler.handle(msg, context, ws)
			end
			ws.onclose do
				context.web_sockets.delete(ws)
			end
		end
	end
end

