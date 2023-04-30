require_relative '../web/context'
require_relative '../web/command_handler'
require_relative '../web/router'

module Web
class FakeRequest
	attr_reader :params
	attr_reader :headers
	alias :POST :params

	def initialize(params, headers={})
		@params = params
		@headers = headers
	end
end

class MockWs
	attr_accessor :received
	def initialize
		@received = []
	end

	def send(msg)
		@received.push msg
	end

	def last
		@received[@received.length - 1]
	end
end

describe "WSHandler" do
	it "Registering works" do
		context = Context.new
		ws = MockWs.new
		
		expect(context.players.length).to eql 0

		result = PlayerController.new(context, FakeRequest.new({username: 'Alex'})).register
		id = JSON.load(result[2])["id"]
		expect(context.players.length).to eql 1

	end
	it "Registering a game without user header won't work" do
		context = Context.new
		expect {
			result = GameController.new(context, FakeRequest.new({})).create
		}.to raise_error
end
it "Registering a game when logged in will work" do
	context = Context.new
	player = PlayerWithWs.new('testuser')
	context.register_player(player)
	game = nil
	
	expect {
		result = GameController.new(context, FakeRequest.new({}, {'X-Poker-Playerid' => player.id})).create
		game = context.games[0]
	}.not_to raise_error

	ws = MockWs.new
	context.web_sockets << ws

	expect(player.web_socket).to eql nil

	CommandHandler.handle('register;' + player.id, context, ws)

	expect(player.web_socket).to eql ws

	player_two = PlayerWithWs.new('testplayer2')
	context.register_player(player_two)

	ws_two = MockWs.new
	context.web_sockets << ws_two
	CommandHandler.handle('register;' + player_two.id, context, ws_two)

	expect(player.current_game.players.length).to eql 1

	GameController.new(context, FakeRequest.new({game_id: game.id}, {'X-Poker-Playerid' => player_two.id})).join
	
	expect(JSON.load(ws.last)['type']).to eql 'game_changed'
	expect(player.current_game.players.length).to eql 2

	GameController.new(context, FakeRequest.new({prompt: 'Ticket-1'}, {'X-Poker-Playerid' => player.id})).change_prompt

	GameController.new(context, FakeRequest.new({}, {'X-Poker-Playerid' => player.id})).flip
	expect(JSON.load(ws.last)['type']).to eql 'game_changed'

	context.remove_player_by_ws(ws_two)
	expect(JSON.load(ws.last)['type']).to eql 'game_changed'
	end

	it "Handle Stats works" do
		context = Context.new
		
		ws = MockWs.new
		
		CommandHandler.handle('stats', context, ws)
	end
end

end