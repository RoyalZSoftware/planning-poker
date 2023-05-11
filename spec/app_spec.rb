require_relative '../app/poker'

describe "App" do
	it "Creating two player works" do
		p_one = Poker::Player.new("PlayerOne")
		p_two = Poker::Player.new("PlayerTwo")

		game = Poker::Game.new
		p_one.join(game)
		p_two.join(game)

		p_one.bid = 1
		p_two.bid = 8
		results = game.results(p_one)
		expect(results[0][:name]).to eql "PlayerOne"
		expect(results[0][:value]).to eql 1
		expect(results[1][:name]).to eql "PlayerTwo"
		expect(results[1][:value]).to eql nil
		
		game.flip
		results = game.results
		expect(results[0][:name]).to eql "PlayerOne"
		expect(results[0][:value]).to eql 1
  end
end
