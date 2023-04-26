require_relative '../app/poker'

describe "App" do
	it "Creating two player works" do
		p_one = Poker::Player.new("PlayerOne")
		p_two = Poker::Player.new("PlayerTwo")

		game = Poker::Game.new
		game.add_player(p_one)
		game.add_player(p_two)

		p_one.bid = Poker::Bid.new(1)
		p_two.bid = Poker::Bid.new(8)
		
		game.flip
		game.results
  end
end
