module Cheetah
  
  class SynchronousTransactionalMessenger

    def initialize(options = {})
      @messenger = options.fetch(:messenger_type, TransactionalMessenger).new
    end

    def send_message(message)
      @messenger.send_message message
    end

  end

end
