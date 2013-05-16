require 'httmultiparty'

module Cheetah

  class TransactionalMessenger
    include Logger
    include HTTMultiParty

    base_uri 'https://sysmail.fagms.net'

    def defaults
      {:ACTION => 'SYSTEM'}
    end

    def send_message(message)
      params = {body: defaults.merge(message.params)}

      result = self.class.post("/c/sm", params)

      status_codes = result["systemmail_result"]["emstatuscodes"].split(",")

      raise_errors_if_detected message.params, status_codes

      status_codes
    end

    private

    def raise_errors_if_detected(params, status_codes)
      status_codes.each do |code|
        if TransactionalResponseCodes::ERROR.key? code
          error_message = TransactionalResponseCodes::ERROR[code]
          if TransactionalResponseCodes::ERRORS_TO_LOG.include? code
            logger.info "aid,#{params['AID']},#{params['email']},#{error_message},#{params.inspect}"
          elsif code == TransactionalResponseCodes::SYSTEM_MAINTENANCE_ERROR
            raise CheetahSystemMaintenanceException.new error_message
          else
            raise CheetahException.new error_message
          end
        end
      end
    end

  end

end
