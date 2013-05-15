module Cheetah
  module Logger

    class LogFormatter
      def call(severity, datetime, progname, msg)
        "#{datetime},#{msg}\n"
      end
    end

    def self.included(base)
      base.send :attr_accessor, :logger_out
    end


    def log_file
      if self.logger_out
        self.logger_out
      elsif defined? Rails
        Rails.root.join('log/cheetah_errors.log').to_s
      else
        '/tmp/cheetah_errors.log'
      end
    end

    def logger
      @logger ||= (
        logger = ::Logger.new(self.logger_out)
        logger.formatter = LogFormatter.new
        logger
      )
    end
  end
end
