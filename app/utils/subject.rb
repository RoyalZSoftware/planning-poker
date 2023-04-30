module Poker
    class Subject
        def initialize
            @observers = []
        end

        def subscribe(&callback)
            @observers << callback
        end

        def next(*options)
            @observers.each {|observer| observer.call(options) }
        end
    end
end
