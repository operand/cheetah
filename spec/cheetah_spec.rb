require 'spec_helper'

describe Cheetah::Cheetah do
  before do
    options = {
      :host             => "foo.com",
      :username         => "foo_user",
      :password         => "foo",
      :aid              => "123",
      :whitelist_filter => /@test\.com$/,
      :enable_tracking  => false,
      :messenger        => Cheetah::NullMessenger,
    }
    @messenger  = mock(:messenger)
    options[:messenger].stub(:new).and_return(@messenger)
    @cheetah    = Cheetah::Cheetah.new(options)
  end

  context '#send_email' do
    it 'should send a message to the ebmtrigger api' do
      api             = '/ebm/ebmtrigger1'
      params          = {}
      params['eid']   = :foo
      params['email'] = 'foo@test.com'
      message         = Message.new(api, params)
      Message.should_receive(:new).with(api, params).and_return(message)
      @messenger.should_receive(:send_message).with(message)
      @cheetah.send_email(:foo, 'foo@test.com')
    end
  end

  context '#mailing_list_update' do
    before do
      @api = '/api/setuser1'
    end

    it "should should send a message to the setuser api" do
      params          = {}
      params['sub']   = '123'
      params['email'] = 'foo@test.com'
      message = Message.new(@api, params)
      Message.should_receive(:new).with(@api, params).and_return(message)
      @messenger.should_receive(:send_message).with(message)
      @cheetah.mailing_list_update('foo@test.com', params)
    end
  end

  context '#mailing_list_email_change' do
    before do
      @api = '/api/setuser1'
    end

    it "should should send a message to the setuser api with the old and new emails" do
      params             = {}
      params['email']    = 'foo@test.com'
      params['newemail'] = 'foo2@test.com'
      message = Message.new(@api, params)
      Message.should_receive(:new).with(@api, params).and_return(message)
      @messenger.should_receive(:send_message).with(message)
      @cheetah.mailing_list_email_change('foo@test.com', 'foo2@test.com')
    end
  end
end

