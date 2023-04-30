require_relative '../app/subject'

describe "Subscriber" do
    it "Example" do
        subject = Poker::Subject.new
        x = 0
        
        subject.subscribe do |values|
            x = values[0]
        end
        
        subject.next(1)

        expect(x).to eql 1
    end
end