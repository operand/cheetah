require 'cheetah/message'
require 'cheetah/exception'
require 'cheetah/messenger/messenger'
Dir["#{File.dirname(__FILE__)}/cheetah/**/*.rb"].each {|f| require f}

module Cheetah

  def self.send_email(eid, email, params = {})
    path = "/ebm/ebmtrigger1"
    params['eid']   = eid
    params['email'] = email
    self.do_send(Message.new(path, params))
  end

  def self.mailing_list_update(sub_id, email, params = {})
    path = "/api/setuser1"
    params['sub']   = sub_id
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
