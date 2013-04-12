require 'resque-retry'

module Cheetah

  class ResqueTransactionalMessenger
    extend Resque::Plugins::Retry

    @queue = :cheetah
    @retry_limit = 4
    @retry_delay = 60
    @retry_exceptions = [Timeout::Error]

    def initialize(options = {})
    end

    def send_message(message)
      params = self.class.map_attachments message.params do |attachment|
        self.class.serialize_attachment attachment
      end

      Resque.enqueue self.class, params
    end

    def self.perform(params)
      deserialized = map_attachments params do |attachment|
        deserialize_attachment attachment
      end

      messenger = TransactionalMessenger.new
      messenger.send_message Message.new(nil, deserialized)
    end

    def self.map_attachments(params)
      params.each_with_object({}) do |(k,v),p|
        p[k] =
          if k =~ /^SYSTEMMAIL_ATTACHMENT/
            yield v
          else
            v
          end
      end
    end

    def self.serialize_attachment(attachment)
      case attachment
      when UploadIO
        {
          content_type: attachment.content_type,
          original_filename: attachment.original_filename,
          body: Base64.encode64(attachment.read)
        }
      when File
        {
          content_type: nil,
          original_filename: File.basename(attachment.path),
          body: Base64.encode64(attachment.read)
        }
      else
        raise UnsupportedAttachmentTypeError,
          "#{attachment.class} is not a supported attachment type. Please use a File or UploadIO object."
      end
    end

    def self.deserialize_attachment(params)
      UploadIO.new StringIO.new(Base64.decode64(params['body'])),
        params['content_type'],
        params['original_filename']
    end

    class UnsupportedAttachmentTypeError < StandardError; end

  end

end
