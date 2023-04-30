require_relative './base_model'

module Web
    class PlayerWithWs < Poker::Player
        attr_accessor :web_socket
    end
end