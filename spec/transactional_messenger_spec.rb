require 'spec_helper'

describe Cheetah::TransactionalMessenger do
  
  before do
    @messenger = Cheetah::TransactionalMessenger.new
  end

  context "#send_message" do
    it "should post parameters cheetahmail endpoints" do
      params = {foo: 'bar'}
      expected_params = {body: {:ACTION => "SYSTEM"}}
      expected_params[:body].merge! params

      Cheetah::TransactionalMessenger.default_options[:base_uri].should eql('http://sysmail.fagms.net')

      response = {"systemmail_result" => { "emstatuscodes" => "+10"}}

      @message = Message.new(nil, params)

      Cheetah::TransactionalMessenger.should_receive(:post).with("/c/sm", expected_params).and_return(response)

      @messenger.send_message(@message)
    end

    it "should raise an exception for status code indicating errors" do
      params = {foo: 'bar'}
      expected_params = {body: {:ACTION => "SYSTEM"}}
      expected_params[:body].merge! params

      response = {"systemmail_result" => { "emstatuscodes" => "-40"}}

      @message = Message.new(nil, params)

      Cheetah::TransactionalMessenger.should_receive(:post).with("/c/sm", expected_params).and_return(response)

      lambda { @messenger.send_message(@message) }.should raise_error(CheetahException)
    end

  end

end
