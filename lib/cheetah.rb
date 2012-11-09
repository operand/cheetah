require 'cheetah/message'
require 'cheetah/exception'
require 'cheetah/messenger/messenger'
Dir["#{File.dirname(__FILE__)}/cheetah/messenger/*.rb"].each {|f| require f}

module Cheetah
  class Cheetah

    UNSUB_REASON = {
      'a'	=> 'abuse complaint',
      'b'	=> 'persistent bounces',
      'd'	=> 'deleted via admin interface',
      'e'	=> 'email to remove address (from mailing)',
      'i'	=> 'request via api',
      'k'	=> 'bulk unsubscribe',
      'r'	=> 'request in reply to mailing',
      'w'	=> 'web-based unsubscribe (link from mailing)',
    }

    # options hash example (all fields are required, except whitelist_filter):
    # {
    #   :host             => 'ebm.cheetahmail.com'
    #   :username         => 'foo_api_user'
    #   :password         => '12345'
    #   :aid              => '67890'                  # the 'affiliate id'
    #   :whitelist_filter => //                       # if set, emails will only be sent to addresses which match this pattern
    #   :enable_testing  => true                      # if true, non-production emails can be set (default is false)
    #   :messenger        => Cheetah::ResqueMessenger
    # }
    def initialize(options)
      @messenger = options[:messenger].new(options)
    end

    def send_email(eid, email, params = {})
      path = "/ebm/ebmtrigger1"
      params['eid']   = eid
      params['email'] = email
      @messenger.send_message(Message.new(path, params))
    end

    def mailing_list_update(email, params = {})
      path = "/api/setuser1"
      params['email'] = email
      @messenger.send_message(Message.new(path, params))
    end

    def mailing_list_email_change(oldemail, newemail)
      path = "/api/setuser1"
      params             = {}
      params['email']    = oldemail
      params['newemail'] = newemail
      @messenger.send_message(Message.new(path, params))
    end

  end
end
