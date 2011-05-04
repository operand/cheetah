require File.dirname(__FILE__) + '/spec_helper'

describe Messenger do

  before(:each) do
  end

  context "#do_request" do
    [CheetahPermanentException, CheetahAuthorizationException, Exception].each do |exception|
      it "should suppress #{exception}" do
        Messenger.instance.stub(:login).and_raise(CheetahPermanentException)
        Messenger.instance.stub(:do_post).and_raise(exception)
        Messenger.instance.do_request "", {}
      end
    end
  end

  context '#do_post' do
    it "should blah"
  end

  context '#login' do
    it "should blah"
  end

end

