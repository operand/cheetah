#encoding: utf-8

require 'spec_helper'

describe Cheetah::SynchronousTransactionalMessenger do
  
  before do
    @transactional_messenger = mock(:transactional_messenger)
    Cheetah::TransactionalMessenger.stub(:new).and_return(@transactional_messenger)
 
    @messenger = Cheetah::SynchronousTransactionalMessenger.new 
  end

  context "#send_message" do
    it "should delegate delivery to transactional messenger" do
      message = mock(:message)

      @transactional_messenger.should_receive(:send_message).with(message)

      @messenger.send_message message
    end
  end
  
end