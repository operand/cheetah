require 'spec_helper'

# through this class I'm also testing the base messenger class
describe Cheetah::SynchronousMessenger do
  before do
    @options = {
      :host             => "foo.com",
      :username         => "foo_user",
      :password         => "foo",
      :aid              => "123",
      :whitelist_filter => /@test\.com$/,
      :enable_tracking  => false,
    }
    @messenger = Cheetah::SynchronousMessenger.new(@options)
    stub_http
  end

  context ".do_send" do
    before do
      @message   = Message.new("/",{})
      @resp      = mock(:resp).as_null_object
      @http      = mock(:http).as_null_object
      @http.stub(:post).and_return(@resp)
      Net::HTTP.stub(:new).and_return(@http)
    end

    it "should send a http post" do
      @http.should_receive(:post)
      @messenger.do_send(@message)
    end

    it "should raise CheetahPermanentException when there's an authorization problem" do
      @resp.stub(:code).and_return('200')
      @resp.stub(:body).and_return('err:auth')
      lambda { @messenger.do_send(@message) }.should raise_error(CheetahPermanentException)
    end

    it "should raise CheetahPermanentException when there's a permanent error on Cheetah's end" do
      @resp.stub(:code).and_return('400')
      lambda { @messenger.do_send(@message) }.should raise_error(CheetahPermanentException)
    end

    it "should raise CheetahTemporaryException when there's a temporary error on Cheetah's end" do
      @resp.stub(:code).and_return('500')
      lambda { @messenger.do_send(@message) }.should raise_error(CheetahTemporaryException)
    end

    it "should raise CheetahTemporaryException when there's a temporary error on Cheetah's end" do
      @resp.stub(:code).and_return('200')
      @resp.stub(:body).and_return('err:internal error')
      lambda { @messenger.do_send(@message) }.should raise_error(CheetahTemporaryException)
    end
  end

  context '.send_message' do
    before do
      @params = {'email' => 'foo@test.com'}
      @message = Message.new('/', @params)
    end

    context 'with a whitelist filter' do
      before do
        @params[:whitelist_filter] = /test\.com$/
          @message = Message.new('/', @params)
      end
    end

    context 'with an email that matches the whitelist filter' do

      it 'should send' do
        @messenger.should_receive(:do_send).with(@message)
        @messenger.send_message(@message)
      end

      it "should suppress emails that do not match the whitelist" do
        email = 'foo@bar.com'
        @message.params['email'] = email
        @messenger.should_not_receive(:do_send)
        @messenger.send_message(@message)
      end

      context "with :enable_tracking set to true" do
        before do
          @options[:enable_tracking] = true
          @messenger = Cheetah::SynchronousMessenger.new(@options)
        end

        it 'should not set the test parameter' do
          @message.params.should_not_receive(:[]=).with('test', '1')
          @messenger.send_message(@message)
        end
      end

      context "with :enable_tracking set to false" do
        before do
          @options[:enable_tracking] = false
          @messenger = Cheetah::SynchronousMessenger.new(@options)
        end

        it 'should set the test parameter' do
          @message.params.stub(:[]=)
          @message.params.should_receive(:[]=).with('test', '1')
          @messenger.send_message(@message)
        end
      end
    end
  end
end
