alias MessageList = Array(String)
alias ErrorMessages = MessageList | Hash(String, MessageList)

class Serializer
end

class LoginSerializer < Serializer
  def initialize(@input_data)
  end
end



