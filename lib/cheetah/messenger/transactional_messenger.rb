require 'cheetah/transactional_response_codes'

require 'httmultiparty'

module Cheetah
  
  class TransactionalMessenger
    include HTTMultiParty

    base_uri 'http://sysmail.fagms.net'

    def defaults
      {:ACTION => 'SYSTEM'}
    end

    def send_message(message)
      params = {body: defaults.merge(message.params)}

      result = self.class.post("/c/sm", params)

      status_codes = result["systemmail_result"]["emstatuscodes"].split(",")

      raise_errors_if_detected status_codes

      status_codes
    end

    private

    def raise_errors_if_detected(status_codes)
      status_codes.each do |code|
        if TransactionalResponseCodes::ERROR.key? code
           raise CheetahException.new TransactionalResponseCodes::ERROR[code]
        end
      end
    end

  end

end
