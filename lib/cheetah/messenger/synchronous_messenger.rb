module Cheetah
  class SynchronousMessenger < Messenger
    def do_send(message)
      do_request(message)
    end
  end
end
