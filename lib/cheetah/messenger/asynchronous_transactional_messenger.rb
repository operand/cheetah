module Cheetah
  
  class AsynchronousTransactionalMessenger

    def send(message)
      Resque.enqueue(self.class, message.to_params)
    end

    def self.perform(message)
      messenger = TransactionalMessenger.new
      messenger.send(message)
    end

  end

end

