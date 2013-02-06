module Cheetah
  
  class SynchronousTransactionalMessenger

    def initialize
      @messenger = TransactionalMessenger.new
    end

    def send_message(message)
      @messenger.send_message message
    end

  end

end
