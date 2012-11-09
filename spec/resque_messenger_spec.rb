require 'spec_helper'
require 'resque'

describe Cheetah::ResqueMessenger do
  before do
    @options = {
      :host             => "foo.com",
      :username         => "foo_user",
      :password         => "foo",
      :aid              => "123",
      :whitelist_filter => /@test\.com$/,
    }
    @messenger = Cheetah::ResqueMessenger.new(@options)
    @message   = Message.new("/",{})
  end

  describe '#do_send' do
    it 'should queue up a job in resque' do
      Resque.should_receive(:enqueue).with(Cheetah::ResqueMessenger, @message, @options)
      @messenger.do_send(@message)
    end
  end

  describe '.perform' do
    it 'should immediately send a message to cheetah' do
      Cheetah::Messenger.should_receive(:new).with(@options).and_return(messenger = mock(:messenger))
      messenger.should_receive(:do_request).with(@message)
      Cheetah::ResqueMessenger.perform(@message, @options)
    end
  end
end
