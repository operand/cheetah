require 'spec_helper'

describe Cheetah::Messenger do
  describe '#do_request' do
    before(:each) do
      params =  {
        host: 'trig.service.bespokeoffers.co.uk',
        username: 'cheetah_api',
        password: 'testing',
        aid: '11111',
        messenger: 'Cheetah::SynchronousMessenger',
        enable_send_not_deployed: false
      }
      @messenger = Cheetah::Messenger.new params
    end


    context '#login' do
      before(:each) do
        FakeWeb.register_uri(:post, 'https://trig.service.bespokeoffers.co.uk/api/login1', body: 'ok',
                             set_cookie: 'example=yes')
      end
      it 'should login using ssl and record the cookies' do
        @messenger.send :login
        @messenger.instance_variable_get(:@cookie).should == 'example=yes'
      end

      it 'should use a non-verified conection' do
        Net::HTTP.any_instance.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
        @messenger.send :login
      end
    end

    context '#do_post' do
      before(:each) do
        FakeWeb.register_uri(:post, 'https://trig.service.bespokeoffers.co.uk/test_path', body: 'ok')
      end
      it 'should send a message using ssl' do
        Net::HTTP.any_instance.should_receive(:post).with('/test_path', "eid=1", nil).and_return(stub(code: :ok, body: :ok))
        @messenger.send :do_post, '/test_path', eid: 1
      end
      it 'should use a non-verified connection' do
        Net::HTTP.any_instance.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)
        @messenger.send :do_post, '/test_path', eid: 1
      end
    end

    it 'should login and send a message' do
      @messenger.should_receive :login
      @messenger.should_receive :do_post
      @messenger.do_request Message.new('/test_path', { eid: 1 })
    end
  end
end
