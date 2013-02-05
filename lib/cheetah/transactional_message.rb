class TransactionalMessage

  attr_reader :params, :attachments

  def initialize(params, attachments = {})
    @params = params
    @attachments = attachments
  end

  def to_params
    @params.merge @attachments
  end

end
