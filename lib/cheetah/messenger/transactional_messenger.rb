require 'httmultiparty'
require 'multiparty'

module Cheetah
  
  class TransactionalMessenger
    include HTTMultiParty

    base_uri 'http://sysmail.fagms.net'

    def defaults
      {:ACTION => 'SYSTEM'}
    end

    def send(message)
      params = {body: defaults.merge(message.to_params)}
      self.class.post("/c/sm", params)
    end
  end

end
