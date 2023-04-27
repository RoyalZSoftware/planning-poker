require_relative '../web/context'
require_relative '../web/command_handler'

class MockWs
	attr_accessor :received
	def initialize
		@received = []
	end

	def send(msg)
		@received << msg
	end

	def last
		@received[@received.length - 1]
	end
end

describe "WSHandler" do
	it "Registering works" do
		context = Web::Context.new
		
		ws = MockWs.new
		
		expect(context.players.length).to eql 0
		Web::CommandHandler.handle('register;Alex', context, ws)
		expect(context.players.length).to eql 1

		Web::CommandHandler.handle('stats', context, ws)
		expect(JSON.load(ws.last)["username"]).to eql "Alex"
		
		Web::CommandHandler.handle('create', context, ws)
		expect(JSON.load(ws.last)).to eql 0
		
		ws_two = MockWs.new
		
		Web::CommandHandler.handle('register;IJustDev', context, ws_two)
		Web::CommandHandler.handle('join;0', context, ws_two)
		Web::CommandHandler.handle('stats', context, ws_two)
		expect(JSON.load(ws_two.last)['current_game']['users'].length).to eql 2
		expect(JSON.load(ws_two.last)['current_game']['state']).to eql 'picking'
		expect(JSON.load(ws_two.last)['current_game']['id']).to eql 0

		Web::CommandHandler.handle('bid;5', context, ws)
		Web::CommandHandler.handle('bid;5', context, ws_two)

		context.web_sockets << ws
		context.web_sockets << ws_two

		Web::CommandHandler.handle('flip', context, ws)

		expected_game_result = JSON.dump([{name: 'Alex', value: 5}, {name: 'IJustDev', value: 5}])

		expect(ws.last).to eql expected_game_result
		expect(ws_two.last).to eql expected_game_result

		Web::CommandHandler.handle('set_prompt;Ticket-69', context, ws)
		expect(JSON.load(ws.last)).to eql 'new_prompt;Ticket-69'
		expect(JSON.load(ws_two.last)).to eql 'new_prompt;Ticket-69'
	end

	it "Handle Stats works" do
		context = Web::Context.new
		
		ws = MockWs.new
		
		Web::CommandHandler.handle('stats', context, ws)
	end
end
