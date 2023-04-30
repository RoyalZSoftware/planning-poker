require 'json'

module Web
    class BaseController
        def initialize(context, request)
            @context = context
            @request = request
        end

        def set_player
            player_id = @request.headers["X-Poker-Playerid"]
            raise "Please pass the X-Poker-Playerid Header" if player_id.nil?

            @player = @context.find_player_by_id(player_id)
            raise "User not registered yet." if @player.nil?
        end

        def params
            @request.POST.transform_keys(&:to_sym)
        end
        
        protected

        def ok(data = nil)
            [200, {ContentType: 'application/json', 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Headers': '*', 'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'}, JSON.dump(data)]
        end
    end
end