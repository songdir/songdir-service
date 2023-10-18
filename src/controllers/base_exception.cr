require "grip"

class BaseExceptionController < Grip::Controllers::Exception
  def call(context : Context)
    context.json({"message" => context.exception.not_nil!.to_s})
  end
end
