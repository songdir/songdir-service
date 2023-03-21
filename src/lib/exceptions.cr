class APIException < Exception
  property body

  def initialize(@body : String | Hash(String, Array(String)))
    if @body.is_a?(String)
      @body = {
        "errors" => [@body.to_s]
      }
    end
  end

  def status()
    500
  end

  def to_s
    @body.to_s
  end
end


class ValidationError < APIException
  def status
    400
  end
end


class UnAuthorized < APIException
  def status
    401
  end
end


class LoginTimeout < APIException
  def status
    440
  end
end
