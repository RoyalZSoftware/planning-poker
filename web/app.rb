require_relative '../app/poker'
require_relative './context'
require_relative './command_handler'
require_relative './router'
require 'faye/websocket'
require 'rack'

context = Web::Context.new

module Rack
  class Request
    attr_accessor :headers
  end
end

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    context.web_sockets << ws

    ws.on :message do |event|
      Web::CommandHandler.handle(event.data, context, ws)
    end

    ws.on :close do |event|
      context.remove_player_by_ws(ws)
      ws = nil
    end

    ws.rack_response
  else
    request = Rack::Request.new(env)
    headers = Hash[*env.select {|k,v| k.start_with? 'HTTP_'}
      .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
      .collect {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
      .sort
      .flatten]

    request.headers = headers
    Web::Router.new(request, context).route!
  end
end

