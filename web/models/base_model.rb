require 'securerandom'

module Web
    module BaseModel

        def self.included(base)
            base.class_eval do
                def id
                    @_id ||= SecureRandom.hex
                end
            end
        end
    end
end