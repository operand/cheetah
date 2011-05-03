require 'cheetah/exception'
require 'cheetah/message'
require 'cheetah/messenger'

module Cheetah

  # determines if and how to send based on configuration
  def self.send(message)
    raise "not finished yet!"

    if params['email'] =~ CM_WHITELIST_FILTER
      params['test'] = "1" # this makes it so tracking is disabled if we're not sending from production
    end




    case mode
    when 'production'
      # do it later
      Delayed::Job.enqueue Delayed::PerformableMethod.new(self, :do_request, [ path, params ]), priority
    when 'staging'
      # do it later
      params['test'] = "1" # this makes it so tracking is disabled if we're not sending from production
      Delayed::Job.enqueue Delayed::PerformableMethod.new(self, :do_request, [ path, params ]), priority
    when 'development'
      # do it right away, with filtering
      if params['email'] =~ CM_TEST_WHITELIST_FILTER
        params['test'] = "1" # this makes it so tracking is disabled if we're not sending from production
        do_request(path, params)
      else
        log "[SUPPRESSED due to whitelist] request to path '#{path}' with params #{params.inspect}"
      end
    when 'test'
      # do nothing and log it
      log "[SUPPRESSED due to test mode] request to path '#{path}' with params #{params.inspect}"
    else
      raise "Could not determine mode for sending email. Please start your server with the RAILS_ENV environment variable set to 'production', 'staging', 'development', or 'test'."
    end
  end

  ##############################################################################
  public # ok, something to see here :)
  ##############################################################################

  def self.send_email(eid, email, params = {})
    path = "/ebm/ebmtrigger1"
    params['eid']   = eid
    params['email'] = email
    self.send(Message.new(path, params))
  end

  def self.mailing_list_update(sub_id, email, params = {})
    path = "/api/setuser1"
    params['sub']   = sub_id
    params['email'] = email
    params['a']     = 1 # this makes it so that the subscriptions passed in the call are used as the users complete set of subscriptions
    self.send(Message.new(path, params))
  end

  def self.mailing_list_email_change(oldemail, newemail)
    path = "/api/setuser1"
    params             = {}
    params['email']    = oldemail
    params['newemail'] = newemail
    self.send(Message.new(path, params))
  end

  # This returns a users information as it appears in Cheetah's database.
  # No use yet for this as of now, other than for testing.
  # Also, it's unfinished.
  def self.get_user(email)
    raise "not implemented yet!"
    path = "/api/getuser1"
    params          = {}
    params['email'] = email
    self.send(Message.new(path, params))
  end
end
