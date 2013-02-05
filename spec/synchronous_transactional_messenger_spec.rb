require 'spec_helper'

describe Cheetah::SynchronousTransactionalMessenger do
  
  before do
    @transactional_messenger = mock(:transactional_messenger)
    messenger_type = Cheetah::TransactionalMessenger
    messenger_type.stub(:new).and_return(@transactional_messenger)
 
    @messenger = Cheetah::SynchronousTransactionalMessenger.new(messenger_type: messenger_type)
  end

  context "#send_message" do
    it "delegates delivery to transactional messenger" do
      message = mock(:message)

      @transactional_messenger.should_receive(:send_message).with(message)

      @messenger.send_message message
    end
  end

end