require 'spec_helper'

describe Cheetah do


  context '.send_email' do
    before do
      @eid    = :foo
      @email  = 'foo@test.com'
      @params = {
        'eid'   => @eid,
        'email' => @email,
      }
      @message = Message.new('/ebm/ebmtrigger1', @params)
      Message.should_receive(:new).with('/ebm/ebmtrigger1', @params).and_return(@message)
    end

    it 'should send' do
      Cheetah.should_receive(:do_send).with(@message)
      Cheetah.send_email(@eid, @email)
    end

    it "should send a Message object to the messenger instance" do
      CM_MESSENGER.instance.should_receive(:do_send).with(@message)
      Cheetah.send_email(@eid, @email)
    end

    it "should suppress emails that do not match the whitelist" do
      @email = 'foo@bar.com'
      @params['email'] = @email
      CM_MESSENGER.instance.should_not_receive(:do_send)
      Cheetah.send_email(@eid, @email)
    end

    it 'should set the test parameter unless CM_ENABLE_TRACKING is true' do
      CM_ENABLE_TRACKING.should be_false # after all this is in test mode
      @message.params.should_receive(:[]=).with('test', '1')
      Cheetah.send_email(@eid, @email)
    end
  end

  context '.mailing_list_update' do
    before do
      @api = '/api/setuser1'
    end

    it "should should send a message to the setuser api" do
      params          = {}
      params['sub']   = '123'
      params['email'] = 'foo@test.com'
      message = Message.new(@api, params)
      Message.should_receive(:new).with(@api, params).and_return(message)
      CM_MESSENGER.instance.should_receive(:do_send).with(message)
      Cheetah.mailing_list_update('foo@test.com', params)
    end
  end

  context '.mailing_list_email_change' do
    before do
      @api = '/api/setuser1'
    end

    it "should should send a message to the setuser api with the old and new emails" do
      params             = {}
      params['email']    = 'foo@test.com'
      params['newemail'] = 'foo2@test.com'
      message = Message.new(@api, params)
      Message.should_receive(:new).with(@api, params).and_return(message)
      CM_MESSENGER.instance.should_receive(:do_send).with(message)
      Cheetah.mailing_list_email_change('foo@test.com', 'foo2@test.com')
    end
  end
end

