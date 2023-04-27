require_relative './base_controller'
require_relative '../models/observable_player'

module Web
    class PlayerController < BaseController
        def register
            username = params[:username]
            raise "No username provided" if username.nil?

            player = ObservablePlayer.new(username)
            @context.register_player(player)
            ok({
                id: player.id,
                username: player.username,
            })
        end
    end
end