require 'singleton'
require 'net/http'
require 'net/https'
require 'uri'

class Client
  include Singleton

  ##############################################################################
  private # nothing to see here, move along :P
  ##############################################################################

  def initialize
    @cookie = nil
  end

  # determines if and how to send based on configuration
  def send(path, params, priority = 0)
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

  # sends the request and processes any exceptions
  def do_request(path, params)
    log_msg = "request to path #{path} with params #{params.inspect}"
    begin
      login unless @cookie
      initheader = {'Cookie' => @cookie || ''}
      params['aid'] = CM_AID
      resp = do_post(path, params, initheader)
    rescue CheetahAuthorizationException => e
      # it may be that the cookie is stale. clear it and immediately retry. 
      # if it hits another authorization exception in the login function then it will come back as a permanent exception
      log_msg = "ERROR: #{e}: #{log_msg}"
      @cookie = nil
      retry
    rescue CheetahTemporaryException, Timeout::Error => e
      # temporary exceptions should be retried.
      # raise them so that the Delayed plugin considers this a failure and keeps it in the queue
      log_msg = "ERROR: #{e}: #{log_msg}"
      raise e
    rescue CheetahPermanentException, Exception => e
      # suppress all permanent or unknown errors and log them
      # this is because the Delayed plugin will keep retrying otherwise
      log_msg = "ERROR: #{e}: #{log_msg}"
    ensure
      log log_msg
    end
  end

  # actually sends the request and raises any exceptions
  def do_post(path, params, initheader = nil)
    http              = Net::HTTP.new(CM_HOST, 443)
    http.read_timeout = 5
    http.use_ssl      = true
    http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
    data              = params.to_a.map { |a| "#{a[0]}=#{a[1]}" }.join("&")
    resp              = http.post(path, data, initheader)

    raise CheetahTemporaryException,     "failure:'#{path}?#{data}', HTTP error: #{resp.code}"              if resp.code =~ /5../
      raise CheetahPermanentException,     "failure:'#{path}?#{data}', HTTP error: #{resp.code}"              if resp.code =~ /[^2]../
      raise CheetahAuthorizationException, "failure:'#{path}?#{data}', Cheetah error: #{resp.body.strip}" if resp.body =~ /^err:auth/
      raise CheetahTemporaryException,     "failure:'#{path}?#{data}', Cheetah error: #{resp.body.strip}" if resp.body =~ /^err:internal error/
      raise CheetahPermanentException,     "failure:'#{path}?#{data}', Cheetah error: #{resp.body.strip}" if resp.body =~ /^err/

      resp
  end

  # sets the instance @cookie variable
  def login
    begin
      log_msg = "(re)logging in-----------"
      path = "/api/login1"
      params              = {}
      params['name']      = CM_USERNAME
      params['cleartext'] = CM_PASSWORD
      @cookie = do_post(path, params)['set-cookie']
    rescue CheetahAuthorizationException => e
      log_msg = "ERROR: #{e}: #{log_msg}"
      raise CheetahPermanentException, "authorization exception while logging in" # this is a permanent exception, it should not be retried
    ensure
      log log_msg
    end
  end

  def log(msg)
    @@log ||= Logger.new("log/cheetah.log")
    @@log.info("[#{Time.now}]: #{msg}") rescue nil
  end

  ##############################################################################
  public # ok, something to see here :)
  ##############################################################################

  def send_email(eid, email, params = {})
    path = "/ebm/ebmtrigger1"
    params['eid']   = eid
    params['email'] = email
    send(path, params)
  end

  def mailing_list_update(sub_id, email, params = {})
    path = "/api/setuser1"
    params['sub']   = sub_id
    params['email'] = email
    #params['a']     = 1 # this makes it so that the subscriptions passed in the call are used as the users complete set of subscriptions
    send(path, params)
  end

  def mailing_list_email_change(oldemail, newemail)
    path = "/api/setuser1"
    params             = {}
    params['email']    = oldemail
    params['newemail'] = newemail
    send(path, params)
  end

  # This returns a users information as it appears in Cheetah's database.
  # No use yet for this as of now, other than for testing.
  # Also, it's unfinished.
  def get_user(email)
    raise "not implemented yet!"
    path = "/api/getuser1"
    params          = {}
    params['email'] = email
    send(path, params)
  end

end
