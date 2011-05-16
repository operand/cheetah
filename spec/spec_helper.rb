require 'cheetah'
require 'net/http'

CM_HOST             = "foo.com"
CM_USERNAME         = "foo_user"
CM_PASSWORD         = "foo"
CM_AID              = "123"                   # the 'affiliate id'
CM_SUB_ID           = "456"                   # the test mailing list id
CM_WHITELIST_FILTER = /@test\.com$/           # if set, emails will only be sent to addresses which match this pattern
CM_ENABLE_TRACKING  = false                   # determines whether cheetahmail will track the sending of emails for reporting purposes. this should be disabled outside of production 
CM_MESSENGER        = Cheetah::NullMessenger  # the class used for sending api requests to cheetahmail.

Delayed::Worker.backend = :active_record # this is apparently needed to avoid a bug in delayed job

Rspec.configure do |config|                                                                                                                        
  config.before(:each) do
    Net::HTTP.stub(:new).and_return(mock(:http).as_null_object) # to block any http requests
  end
end

