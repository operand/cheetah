require 'cheetah'

# blocks http requests and throws an exception
require 'timecop'
require 'fakeweb'
FakeWeb.allow_net_connect = false

# use this to explicitly block http requests.
# but only use it if you know you should.
# don't blanket your specs with it.
def stub_http
  Net::HTTP.stub(:new).and_return(mock(:http).as_null_object)
end

