require 'spec_helper'

describe Cheetah::Cheetah do
  before do
    options = {
      :host             => "foo.com",
      :username         => "foo_user",
      :password         => "foo",
      :aid              => "123",
      :whitelist_filter => /@test\.com$/,
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

  context '#send_transactional_email' do
    before do
      options = {
        :transactional_messenger        => Cheetah::NullMessenger,
      }
      @messenger  = mock(:transactional_messenger)
      options[:transactional_messenger].stub(:new).and_return(@messenger)
      @cheetah    = Cheetah::Cheetah.new(options)      
    end

    it 'should send a message using transactional mail api' do
      params          = {"FNAME" => "James"}
      params['AID']   = :foo
      params['email'] = 'foo@test.com'
      message         = Message.new(nil, params)
      attachments     = {'test.jpg' => '123889'}
      merged_params   = params.merge attachments
      
      Message.should_receive(:new).with(nil, merged_params).and_return(message)
      @messenger.should_receive(:send_message).with(message)

      @cheetah.send_transactional_email(:foo, 'foo@test.com', {"FNAME" => "James"}, attachments)
    end
  end

end

