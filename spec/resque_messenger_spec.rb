require 'spec_helper'
require 'resque'

describe Cheetah::ResqueMessenger do
  describe '#do_send' do
    it 'should queue up a job in resque' do
      message = mock(:message)
      Resque.should_receive(:enqueue).with(Cheetah::ResqueMessenger, message)
      Cheetah::ResqueMessenger.instance.do_send(message)
    end
  end

  describe '.perform' do
    it 'should immediately send a message to cheetah' do
      message = mock(:message)
      Cheetah::ResqueMessenger.should_receive(:do_request).with(message)
      Cheetah::ResqueMessenger.perform(message)
    end
  end
end
