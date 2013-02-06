require 'spec_helper'

describe Cheetah::ResqueTransactionalMessenger do

  before do
    @transactional_messenger = mock(:transactional_messenger)
    Cheetah::TransactionalMessenger.stub(:new).and_return(@transactional_messenger)
 
    @messenger = Cheetah::ResqueTransactionalMessenger.new
  end

  context "#send_message" do
    it "should queue message for delivery" do
      params = {foo: 'bar'}
      message = mock(:message)

      message.should_receive(:params).and_return(params)
      Resque.should_receive(:enqueue).with(@messenger.class, params)

      @messenger.send_message message
    end
  end

  context "#perform" do
    it "should recompose and deliver message" do
      params = {foo: 'bar'}
      messenger = mock(:messenger)
      message = mock(:message)

      Cheetah::TransactionalMessenger.should_receive(:new).and_return(messenger)
      Message.should_receive(:new).with(nil, params).and_return(message)
      messenger.should_receive(:send_message).with(message)

      Cheetah::ResqueTransactionalMessenger.perform params
    end
  end

end
