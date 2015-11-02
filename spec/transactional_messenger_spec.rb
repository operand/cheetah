require 'spec_helper'

describe Cheetah::TransactionalMessenger do

  before do
    @messenger = Cheetah::TransactionalMessenger.new
    @messenger.logger_out = StringIO.new
  end

  context "#send_message" do
    before(:each) do
      params = { foo: 'bar', 'AID' => 12345, 'email' => 'test@test.com' }
      expected_params = {body: {:ACTION => "SYSTEM"}}
      expected_params[:body].merge! params
      @message = Message.new(nil, params)
    end
    it 'should define base_uri' do
      Cheetah::TransactionalMessenger.default_options[:base_uri].should eql('https://sysmail.fagms.net')
    end
    it "should post parameters to cheetahmail endpoints" do
      response = '<systemmail_result><emstatuscodes>+10</emstatuscodes></systemmail_result>'
      FakeWeb.register_uri(:post, 'https://sysmail.fagms.net/c/sm', body: response, content_type: 'text/xml' )
      @messenger.send_message(@message)
    end
    it "should raise an exception for status codes indicating errors" do
      response = '<systemmail_result><emstatuscodes>-40</emstatuscodes></systemmail_result>'
      FakeWeb.register_uri(:post, 'https://sysmail.fagms.net/c/sm', body: response, content_type: 'text/xml' )
      lambda { @messenger.send_message(@message) }.should raise_error(CheetahException)
    end
    it 'should raise a CheetahSystemMaintenanceException' do
      response = "<systemmail_result><emstatuscodes>#{Cheetah::TransactionalResponseCodes::SYSTEM_MAINTENANCE_ERROR}</emstatuscodes></systemmail_result>"
      FakeWeb.register_uri(:post, 'https://sysmail.fagms.net/c/sm', body: response, content_type: 'text/xml' )
      lambda { @messenger.send_message(@message) }.should raise_error(CheetahSystemMaintenanceException)
    end

    context 'undeliverable address errors' do
      Cheetah::TransactionalResponseCodes::ERRORS_TO_LOG.each do |error_code|
        it "should log #{error_code} responses" do
          response = "<systemmail_result><emstatuscodes>#{error_code}</emstatuscodes></systemmail_result>"
          FakeWeb.register_uri(:post, 'https://sysmail.fagms.net/c/sm', body: response, content_type: 'text/xml' )
          Timecop.freeze(now = Time.now) do
            @messenger.send_message(@message)
          end
          expected = "#{now},aid,12345,test@test.com,#{Cheetah::TransactionalResponseCodes::ERROR[error_code]},#{@message.params.inspect}\n"
          @messenger.logger_out.string.should == expected
        end
      end
      it 'should log when no params are provided' do
        @message = Message.new(nil, {})
        error_code = Cheetah::TransactionalResponseCodes::ERRORS_TO_LOG.first
        response = "<systemmail_result><emstatuscodes>#{Cheetah::TransactionalResponseCodes::ERRORS_TO_LOG.first}</emstatuscodes></systemmail_result>"
        FakeWeb.register_uri(:post, 'https://sysmail.fagms.net/c/sm', body: response, content_type: 'text/xml' )
        Timecop.freeze(now = Time.now) do
          @messenger.send_message(@message)
        end
        expected = "#{now},aid,,,#{Cheetah::TransactionalResponseCodes::ERROR[error_code]},#{@message.params.inspect}\n"
        @messenger.logger_out.string.should == expected
      end
    end
  end
end
