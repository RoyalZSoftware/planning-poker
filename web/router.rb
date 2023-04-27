require_relative './controller/player_controller'
require_relative './controller/game_controller'

module Web
    class Router
        def initialize(request, context)
            @request = request
            @context = context
        end

        def route!
            begin
            post '/register' do
                return PlayerController.new(@context, @request).register
            end
            post '/create' do
                return GameController.new(@context, @request).create
            end
            post '/join' do
                return GameController.new(@context, @request).join
            end
            post '/change_prompt' do
                return GameController.new(@context, @request).change_prompt
            end
            post '/bid' do
                return GameController.new(@context, @request).bid
            end
            post '/flip' do
                return GameController.new(@context, @request).flip
            end
            get '/stats' do
                return GameController.new(@context, @request).stats
            end
        rescue => ex
            return [400, {}, JSON.dump({error: ex})]
        end
        end

        private

        def post(path, &block)
            register_route(path, 'post') do yield end
        end

        def get(path, &block)
            register_route(path, 'get') do yield end
        end
        
        def register_route(path, method, &block)
            if @request.path == path
                return [404, {}, "Not Found"] if method == 'post' && !@request.post?

                yield
            end
        end
    end
end