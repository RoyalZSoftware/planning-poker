require_relative './base_model'

module Web
    class ObservablePlayer < Poker::Player
        include BaseModel
        attr_accessor :web_socket
    end
end