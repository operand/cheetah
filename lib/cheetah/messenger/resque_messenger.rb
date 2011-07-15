require 'resque'

module Cheetah
  # this is both extends Messenger and implements the Resque worker interface
  class ResqueMessenger < Messenger
    @queue = :cheetah

    def do_send(message)
      Resque.enqueue(self.class, message, @options)
    end

    def self.perform(message, options)
      Messenger.new(options).do_request(message)
    end
  end
end
