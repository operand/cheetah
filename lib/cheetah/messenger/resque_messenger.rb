require 'resque-retry'

module Cheetah
  # this is both extends Messenger and implements the Resque worker interface
  class ResqueMessenger < Messenger
    extend Resque::Plugins::ExponentialBackoff

    @queue = :cheetah
    @retry_exceptions = [Timeout::Error]
    @backoff_strategy = [0, 60, 600, 1800, 3600]

    def do_send(message)
      Resque.enqueue(self.class, message, @options)
    end

    def self.perform(message, options)
      ResqueMessenger.new(options).do_request(message)
    end

    def do_request(message)
      tries = 1
      begin
        login unless @cookie
        initheader = {'Cookie' => @cookie || ''}
        message['params']['aid'] = @options[:aid]
        resp = do_post(message['path'], message['params'], initheader)
      rescue CheetahAuthorizationException => e
        # it may be that the cookie is stale. clear it and immediately retry. 
        # if it hits another authorization exception in the login function then it will come back as a permanent exception
        @cookie = nil
        tries += 1
        retry if tries <= MAXIMUM_REQUEST_TRIES
        raise CheetahTooManyTriesException
      end
    end
  end
end
