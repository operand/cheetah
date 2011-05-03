require 'singleton'
require 'net/http'
require 'net/https'
require 'uri'

class Messenger
  include Singleton

  ##############################################################################
  private # nothing to see here, move along :P
  ##############################################################################

  def initialize
    @cookie = nil
  end

  # handles sending the request and processing any connection exceptions
  def do_request(message)
    log_msg = "request to path #{message.path} with params #{message.params.inspect}"
    begin
      login unless @cookie
      initheader = {'Cookie' => @cookie || ''}
      params['aid'] = CM_AID
      resp = do_post(message.path, message.params, initheader)
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

    raise CheetahTemporaryException,     "failure:'#{path}?#{data}', HTTP error: #{resp.code}"            if resp.code =~ /5../
      raise CheetahPermanentException,     "failure:'#{path}?#{data}', HTTP error: #{resp.code}"          if resp.code =~ /[^2]../
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

end
