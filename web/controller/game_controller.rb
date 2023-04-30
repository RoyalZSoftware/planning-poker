module Web
    class GameController < BaseController
        def create
            set_player
            game = Poker::Game.new
            @context.add_game game
            game.add_player(@player)
            ok
        end

        def join
            set_player
            game = @context.find_game_by_id(params[:game_id])

            game.add_player @player
            ok
        end

        def change_prompt
            set_game
            prompt = params[:prompt]
            @game.prompt = prompt
            ok
        end

        def bid
            value = params[:value]
            set_player

            @player.bid = Poker::Bid.new(value)
            ok
        end

        def flip
            set_game
            @game.flip
            ok
        end

        def stats
            set_game
            results = @game.state == :results ? @game.results : []
            dto = {
                players: @game.players.map do |player|
                    {id: player.id, name: player.username}
                end,
                state: @game.state,
                id: @game.id,
                prompt: @game.prompt,
                results: results
            }

            ok(dto)
        end

        private

        def set_game
            set_player
            @game = @player&.current_game
            raise "Not ingame. Please create or join first" if @game.nil?
        end
    end
end