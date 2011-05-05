require 'spec_helper'

describe Cheetah do


  context '.send_email' do
    before(:each) do
      @eid    = :foo
      @email  = 'foo@buywithme.com'
      @params = {
        'eid'   => @eid,
        'email' => @email,
      }
      @message = Message.new('/ebm/ebmtrigger1', @params)
    end

    it "should send a Message object to the messenger instance" do
      Message.should_receive(:new).with('/ebm/ebmtrigger1', @params).and_return(@message)
      CM_MESSENGER.instance.should_receive(:send).with(@message)
      Cheetah.send_email(@eid, @email)
    end

    it "should suppress emails that do not match the whitelist" do
      @email = 'foo@bar.com'
      @params['email'] = @email
      Message.should_receive(:new).with('/ebm/ebmtrigger1', @params).and_return(@message)
      CM_MESSENGER.instance.should_not_receive(:send)
      Cheetah.send_email(@eid, @email)
    end
  end

  context '.mailing_list_update' do
    before(:each) do
      @api = '/api/setuser1'
    end

    it "should should send a message to the setuser api" do
      params          = {}
      params['sub']   = '123'
      params['email'] = 'foo@buywithme.com'
      params['a']     = 1
      message = Message.new(@api, params)
      Message.should_receive(:new).with(@api, params).and_return(message)
      CM_MESSENGER.instance.should_receive(:send).with(message)
      Cheetah.mailing_list_update('123', 'foo@buywithme.com')
    end
  end

  context '.mailing_list_email_change' do
    it "should should send a message to the setuser api with the old and new emails"
  end
end

