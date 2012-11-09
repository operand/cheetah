require 'spec_helper'

# through this class I'm also testing the base messenger class
describe Cheetah::SynchronousMessenger do
  before do
    @options = {
      :host             => "foo.com",
      :username         => "foo_user",
      :password         => "foo",
      :aid              => "123",
      :enable_tracking  => false,
    }
    @messenger = Cheetah::SynchronousMessenger.new(@options)
    stub_http
  end

  context "#do_send" do
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

    it "should raise CheetahTemporaryException when there's a temporary (server) error on Cheetah's end" do
      @resp.stub(:code).and_return('500')
      lambda { @messenger.do_send(@message) }.should raise_error(CheetahTemporaryException)
    end

    it "should raise CheetahTemporaryException when there's a temporary error on Cheetah's end" do
      @resp.stub(:code).and_return('200')
      @resp.stub(:body).and_return('err:internal error')
      lambda { @messenger.do_send(@message) }.should raise_error(CheetahTemporaryException)
    end
  end

  describe '#send_message' do
    before do
      @params = {'email' => 'foo@test.com'}
      @message = Message.new('/', @params)
    end

    it 'should send' do
      @messenger.should_receive(:do_send).with(@message)
      @messenger.send_message(@message)
    end

    context 'with a whitelist filter' do
      before do
        @options[:whitelist_filter] = /@test\.com$/
        @messenger = Cheetah::SynchronousMessenger.new(@options)
        @message   = Message.new('/', @params)
      end

      context 'and an email that does not match the whitelist filter' do
        before do
          @email = 'foo@bar.com'
        end

        it "should suppress the email" do
          @message.params['email'] = @email
          @messenger.should_not_receive(:do_send)
          @messenger.send_message(@message)
        end
      end

      context 'with an email that matches the whitelist filter' do
        before do
          @email = 'foo@test.com'
        end

        it 'should send' do
          @messenger.should_receive(:do_send).with(@message)
          @messenger.send_message(@message)
        end

        context "with :enable_tracking set to true" do
          before do
            @options[:enable_testing] = false
            @messenger = Cheetah::SynchronousMessenger.new(@options)
          end

          it 'should not set the test parameter' do
            @message.params.should_not_receive(:[]=).with('test', '1')
            @messenger.send_message(@message)
          end
        end

        context "with :enable_testing set to false" do
          before do
            @options[:enable_testing] = true
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
end
