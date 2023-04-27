require_relative '../subject'
require_relative './base_model'

module Web
    class ObservableGame < Poker::Game
        include BaseModel
        
        attr_reader :player_added, :player_removed, :state_changed, :prompt_changed
        
        def initialize(context)
            super
            @prompt_changed = Subject.new
            @state_changed = Subject.new
            @player_added = Subject.new
            @player_removed = Subject.new
        end

        def add_player(player)
            super
            @player_added.next(player)
        end

        def remove_player(player)
            super
            @player_removed.next(player)
        end

        def flip
            super
            puts @state
            @state_changed.next(@state)
        end

        def prompt=(prompt)
            super
            @prompt_changed.next(prompt)
        end
    end
end