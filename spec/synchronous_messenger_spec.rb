require 'spec_helper'

describe Cheetah::SynchronousMessenger do

  context "#send" do
    before do
      @messenger = Cheetah::SynchronousMessenger.instance
      @message   = Message.new("/",{})
      @http      = mock(:http).as_null_object
      @resp      = mock(:resp)
      Net::HTTP.stub(:new).and_return(@http)
    end

    it "should raise CheetahAuthorizationException when there's an authorization problem" do
      pending
      lambda { @messenger.send(@message) }.should raise_error(CheetahAuthorizationException)
    end

    it "should raise CheetahPermanentException when there's a permanent error on Cheetah's end" do
      pending
      lambda { @messenger.send(@message) }.should raise_error(CheetahPermanentException)
    end

    it "should raise CheetahTemporaryException when there's a temporary error on Cheetah's end" do
      @resp.stub(:code).and_return('500')
      @http.stub(:post).and_return(@resp)
      lambda { @messenger.send(@message) }.should raise_error(CheetahTemporaryException)
    end

  end

end
