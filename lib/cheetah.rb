require 'cheetah/exception'
require 'cheetah/client'

module Cheetah

  # forwards any missing methods to the client singleton instance
  def self.method_missing? meth, *args
    Client.instance.send(meth, *args)
  end

end
