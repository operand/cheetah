require 'spec_helper'

describe Cheetah::NullMessenger do
  context "#send" do
    it "should do nothing" do
      @http = mock(:http)
      Net::HTTP.stub(:new).and_return(@http)
      Cheetah::NullMessenger.instance.send(Message.new("/",{}))
    end
  end
end
