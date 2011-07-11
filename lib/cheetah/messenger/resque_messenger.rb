module Cheetah
  class ResqueMessenger < Messenger
    def do_send(message)
      Resque.enqueue(self.class, message)
    end

    def self.perform(message)
      do_request(message)
    end
  end
end
