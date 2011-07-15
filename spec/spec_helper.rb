require 'cheetah'
require 'net/http'

# block http requests
require 'fakeweb'
FakeWeb.allow_net_connect = false

def stub_http
  Net::HTTP.stub(:new).and_return(mock(:http).as_null_object)
end

