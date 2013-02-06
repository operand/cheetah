class Message
  attr_accessor :path, :params

  def initialize path, params
    @path   = path
    @params = params
  end

  def encode_attachments
  end
  
end
