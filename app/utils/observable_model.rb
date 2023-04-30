require_relative './subject'

module Poker
    module ObservableModel
        
        attr_accessor :changed

        def watch_field(name)
            @fields ||= []
            @fields << name
        end

        def self.included(base)
            fields = @fields || []
            base.class_eval do
                klass.changed = Subject.new
                fields.each do |field|
                    define_method "#{field}=" do |value|
                        super
                        @changed.next(self)
                    end
                end
            end
        end
    end
end