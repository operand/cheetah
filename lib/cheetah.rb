require 'cheetah/message'
require 'cheetah/exception'
require 'cheetah/messenger/messenger'
Dir["#{File.dirname(__FILE__)}/cheetah/messenger/*.rb"].each {|f| require f}

module Cheetah

  def self.send_email(eid, email, params = {})
    path = "/ebm/ebmtrigger1"
    params['eid']   = eid
    params['email'] = email
    self.do_send(Message.new(path, params))
  end

  def self.mailing_list_update(email, params = {})
    path = "/api/setuser1"
    #params['sub']   = sub_id
    params['email'] = email
    #params['a']     = 1 # this makes it so that the subscriptions passed in the call are used as the users complete set of subscriptions
    self.do_send(Message.new(path, params))
  end

  def self.mailing_list_email_change(oldemail, newemail)
    path = "/api/setuser1"
    params             = {}
    params['email']    = oldemail
    params['newemail'] = newemail
    self.do_send(Message.new(path, params))
  end

  # this provides a mapping of the unsubscribe reason codes that cheetah uses in their unsubscribe report to the description for each code
  def self.unsub_reason(code)
    {
      'a'	=> 'abuse complaint',
      'b'	=> 'persistent bounces',
      'd'	=> 'deleted via admin interface',
      'e'	=> 'email to remove address (from mailing)',
      'i'	=> 'request via api',
      'k'	=> 'bulk unsubscribe',
      'r'	=> 'request in reply to mailing',
      'w'	=> 'web-based unsubscribe (link from mailing)',
    }[code]
  end

  private #####################################################################

  # determines if and how to send based on configuration
  # returns true if the message was sent
  # false if it was suppressed
  def self.do_send(message)
    if CM_WHITELIST_FILTER and message.params['email'] =~ CM_WHITELIST_FILTER
      message.params['test'] = "1" if CM_ENABLE_TRACKING
      CM_MESSENGER.instance.do_send(message)
      true
    else
      false
    end
  end

end
