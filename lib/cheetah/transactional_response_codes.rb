module Cheetah
  module TransactionalResponseCodes

    ERROR = {
      "-103" => "The supplied number of parameters (fields or tempfields) does not match the supplied _count number of a paragraph.",
      "-102" => "An end tag (##Paragraph_End##) was not found for all start tags (##Paragraph_Start##)",
      "-101" => "The same paragraph –identified by its name –was found within itself. This would lead to an endless loop and is thus forbidden.",
      "-95"  => "Supplied attachments must not exceed a total maximum size of 2 MBytes (2097152 bytes).",
￼     "-92"  => "Content-in-content loop detected. Dynamic content may not contain contents of a higher level. If such 'recursive' content is detected, message creation fails.",
      "-91"  => "The message contains one or more ||Content_n|| placeholders that refer to deleted or non-existent customer Contents.",
      "-90"  => "The message does not have any content. Both Transactional-Email HTML and PLAIN contents are empty.",
      "-80"  => "The mesage’s From:mailbox address could not be resolved.",
      "-70"  =>￼"Not used / reserved",
      "-60"  => "Not used / reserved",
      "-53"  => "It is not possible to dispatch messages to the desired recipient because the recipient mailbox address is marked as a global hardbounce within the profiletype.",
      "-52"  => "It is not possible to dispatch messages to the desired recipient because the recipient mailbox address is blacklisted.",
      "-51"  => "It is not possible to dispatch messages to the desired recipient because the mailbox address is registered as a complaint recipient address.",
      "-50"  => "Not used / reserved",
      "-41"  => "Recipient given by either 'email' or 'sms' parameter is not granted. This error only occurs when using the interface in test mode.",
      "-40"  => "Authorisation failed.",
      "-30"  => "The Transactional-Email service is disabled due to system maintenance.",
      "-20"  => "The AID (interface identifier) given is not known.",
      "-10"  => "Indicates a system error.",
￼     "-5"   => "The 'email' parameter syntax is not a valid mailbox address.",
      "-4"   => "The mandatory parameter 'email' is missing.",
      "-3"   => "The mandatory parameter 'ACTION' is missing",
      "-2"   =>￼"Not used / reserved",
      "-1"   => "The mandatory parameter 'AID' is missing"
    }

    WARNING = {
      "1" => "not used / reserved",
      "2" => "The mesage’s HTML content is empty",￼
      "3" => "The mesage’s plain content is empty",
      "4" => "Unresolved ReplyTo: mailbox address",
      "5" => "The mesage’s SMS content is empty"
    }

    SUCCESS => {
      "+10" => "Email enqueued successfully",
      "+11" => "SMS enqueued successfully",
      "+12" => "Not used / reserved",
      "+13" => "One or more blind copies of the message were enqeued for BCC: recipients"
    }

  end
end

