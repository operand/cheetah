require 'cheetah/message'
require 'cheetah/messenger/transactional_messenger'

module Cheetah
  
  class ResqueTransactionalMessenger

    @queue = :cheetah

    def send_message(message)
      message.encode_attachments
      Resque.enqueue(self.class, message.params)
    end

    def self.perform(params)
      messenger = TransactionalMessenger.new
      messenger.send_message(Message.new(nil, params))
    end

  end

end
