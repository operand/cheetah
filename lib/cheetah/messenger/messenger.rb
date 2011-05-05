require 'singleton'
require 'net/http'
require 'net/https'
require 'uri'

module Cheetah
  class Messenger
    include Singleton

    private #####################################################################

    def initialize
      @cookie = nil
    end

    # handles sending the request and processing any exceptions
    def do_request(message)
      begin
        login unless @cookie
        initheader = {'Cookie' => @cookie || ''}
        message.params['aid'] = CM_AID
        resp = do_post(message.path, message.params, initheader)
      rescue CheetahAuthorizationException => e
        # it may be that the cookie is stale. clear it and immediately retry. 
        # if it hits another authorization exception in the login function then it will come back as a permanent exception
        @cookie = nil
        retry
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
        raise CheetahPermanentException, "authorization exception while logging in" # this is a permanent exception, it should not be retried
      end
    end

  end
end
