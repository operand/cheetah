require 'spec_helper'

describe Cheetah::TransactionalMessenger do
  
  before do
    @messenger = Cheetah::TransactionalMessenger.new
    stub_http
  end

  context "#send" do
    before do
      @message   = TransactionalMessage.new({})

      @resp      = mock(:resp).as_null_object
      @http      = mock(:http).as_null_object
      @http.stub(:post).and_return(@resp)
      Net::HTTP.stub(:new).and_return(@http)
    end

  end

end
