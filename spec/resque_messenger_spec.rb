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

  describe '#do_request' do
    before do
      @message_hash = { 'path' => '/', 'params' => { 'aid' => 123 } }
    end

    it 'should use a hash representation of the message' do
      @messenger.instance_variable_set(:@cookie, 'cookie') # Set cookie to avoid login
      @messenger.should_receive(:do_post).with('/', {'aid' => '123'}, {'Cookie' => 'cookie'}).and_return(nil)
      @messenger.do_request(@message_hash)
    end

    it 'should only allow three tries before failing' do
      @messenger = Cheetah::ResqueMessenger.new(@options)
      @messenger.instance_variable_set(:@cookie, nil)
      @messenger.should_receive(:login).exactly(3).times.and_raise(CheetahAuthorizationException)
      expect { @messenger.do_request(@message_hash) }.to raise_error(CheetahTooManyTriesException)

    end
  end
end
