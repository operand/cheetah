class SynchronousMessenger < Messenger
  def send(message)
    do_request(message)
  end
end
