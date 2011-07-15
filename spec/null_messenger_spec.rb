require 'spec_helper'

describe Cheetah::NullMessenger do
  context "#send" do
    it "should do nothing" do
      @messenger = Cheetah::NullMessenger.new({
        :host             => "foo.com",
        :username         => "foo_user",
        :password         => "foo",
        :aid              => "123",
        :whitelist_filter => /@test\.com$/,
        :enable_tracking  => false,
      })
      @http = mock(:http)
      @messenger.do_send(Message.new("/",{}))
    end
  end
end
