require 'cheetah/transactional_message'
require 'cheetah/messenger/transactional_messenger'

module Cheetah
  
  class ResqueTransactionalMessenger

    @queue = :cheetah

    def initialize(options = {})
    end

    def send_message(message)
      Resque.enqueue(self.class, message.to_params)
    end

    def self.perform(params)
      messenger = TransactionalMessenger.new
      messenger.send_message(TransactionalMessage.new(params))
    end

  end

end

