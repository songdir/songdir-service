require "grip"

require "./exceptions"

class ExceptionHandler < Grip::Controllers::Http
  def call(context : Context) : Context
    begin
      super(context)
    rescue exception : APIException
      context.put_status(exception.status).json(exception.body)
    end
  end
end
