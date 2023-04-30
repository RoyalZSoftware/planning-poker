require_relative './base_controller'
require_relative '../models/player_with_ws'

module Web
    class PlayerController < BaseController
        def register
            username = params[:username]
            raise "No username provided" if username.nil?

            player = PlayerWithWs.new(username)
            @context.register_player(player)
            ok({
                id: player.id,
                username: player.username,
            })
        end
    end
end