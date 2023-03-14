require "grip"

require "./serializers"

class ExceptionHandler < Grip::Controllers::Http
  def call(context : Context) : Context
    begin
      super(context)
    rescue exception : ValidationError
      context.put_status(exception.status).json(exception.body)
    end
  end
end
