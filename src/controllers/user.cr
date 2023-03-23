require "grip"

require "../lib/request_objects/user"
require "../lib/exception_handler"
require "../lib/serializers/user"
require "../use_cases/signin"
require "../use_cases/signup"
require "../repositories/user"


class SigninController < ExceptionHandler
  def post(context : Context) : Context
    data = context.fetch_json_params
    SigninSerializer.new data, raise_exception: true
    user_repository = UserRepository.new
    usecase = SigninUseCase.new(user_repository: user_repository)
    signin_request = SigninRequest.from_json data
    response = usecase.execute signin_request
    context.put_status(200).json(response)
  end
end


class SignupController < ExceptionHandler
  def post(context : Context) : Context
    data = context.fetch_json_params
    SignupSerializer.new data, raise_exception: true
    user_repository = UserRepository.from_grip_context context
    usecase = SignupUseCase.new(user_repository: user_repository)
    signup_request = SignupRequest.from_json data
    response = usecase.execute signup_request
    context.put_status(200).json(response)
  end
end
