module Cheetah
  
  class SynchronousTransactionalMessenger

    def initialize
      @messenger = TransactionalMessenger.new
    end

    def send(message)
      @messenger.send message
    end

  end

end
