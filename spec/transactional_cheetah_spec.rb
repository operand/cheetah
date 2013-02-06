require 'spec_helper'

describe Cheetah::TransactionalCheetah do
  before do
    options = {
      :messenger => Cheetah::NullMessenger,
    }
    @messenger = mock(:messenger)
    options[:messenger].stub(:new).and_return(@messenger)
    @cheetah = Cheetah::TransactionalCheetah.new(options)
  end

  context '#initialize' do
    it 'should create a Messenger object' do
      Cheetah::TransactionalCheetah.new(messenger: Cheetah::NullMessenger)
    end
    it 'should require a :messenger parameter' do
      expect { Cheetah::TransactionalCheetah.new({}) }.should raise_error(NoMethodError)
    end
  end

  context '#send_transactional_email' do
    it 'should send a message using transactional mail api' do
      params = {"FNAME" => "James"}
      params['AID'] = :foo
      params['email'] = 'foo@test.com'
      params['test.jpg'] =  '123889'

      message = Message.new(nil, params)
      
      Message.should_receive(:new).with(nil, params).and_return(message)
      @messenger.should_receive(:send_message).with(message)

      @cheetah.send_email(:foo, 'foo@test.com', params)
    end
  end

end
