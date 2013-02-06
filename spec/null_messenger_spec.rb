require 'spec_helper'

describe Cheetah::NullMessenger do
  context "#do_send" do
    it "should do nothing" do
      # by using the fakeweb gem we're already ensuring that no http requests are made.
      # calling the method and seeing that no http requests are made is good enough for me.
      @messenger = Cheetah::NullMessenger.new({
        :host             => "foo.com",
        :username         => "foo_user",
        :password         => "foo",
        :aid              => "123",
        :whitelist_filter => /@test\.com$/,
      })
      @messenger.do_send(Message.new("/",{}))
    end
  end
end
