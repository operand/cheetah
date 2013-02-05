class TransactionalMessage

  attr_reader :aid, :email, :params, :attachments

  def initialize(params, attachments = {})
    @params = params
    @attachments = attachments
  end

  def aid
    @params[:AID]
  end

  def email
    @params[:email]
  end

end
