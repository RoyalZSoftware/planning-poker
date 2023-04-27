require_relative '../app/poker'
require_relative './context'
require_relative './command_handler'
require 'faye/websocket'
require 'rack'

context = Web::Context.new

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    context.web_sockets << ws

    ws.on :message do |event|
      ws.send(event.data)
      Web::CommandHandler.handle(event.data, context, ws)
    end

    ws.on :close do |event|
      context.web_sockets.delete(ws)
      ws = nil
    end

    # Return async Rack response
    ws.rack_response

  else
    # Normal HTTP request
    [200, {}, ['Server up and running']]
  end
end

