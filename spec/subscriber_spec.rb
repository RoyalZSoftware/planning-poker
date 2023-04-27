require_relative '../web/subject'

describe "Subscriber" do
    it "Example" do
        subject = Web::Subject.new
        x = 0
        
        subject.subscribe do |values|
            x = values[0]
        end
        
        subject.next(1)

        expect(x).to eql 1
    end
end