class Message
  attr_accessor :path, :params

  def initialize path, params
    @path   = path
    @params = params
  end

end
