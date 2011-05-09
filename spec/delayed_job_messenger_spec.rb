require 'spec_helper'

describe Cheetah::DelayedJobMessenger do
  context "#send" do

    it "should create a delayed job" do
      Delayed::PerformableMethod.stub(:new)
      Delayed::Job.stub(:enqueue)
      Delayed::Job.should_receive(:enqueue)
      Cheetah::DelayedJobMessenger.instance.do_send(Message.new("/",{}))
    end
  end
end
