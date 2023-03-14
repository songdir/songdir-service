require "grip"

require "../serializers/user"
require "../request_objects/user"
require "../use_cases/login"
require "../repositories/user"
require "../lib/exception_handler"


class LoginController < ExceptionHandler
  def post(context : Context) : Context
    data = context.fetch_json_params
    LoginSerializer.new data, raise_exception: true
    user_repository = UserRepository.new
    usecase = LoginUseCase.new(user_repository: user_repository)
    login_request = LoginRequest.from_json data
    response = usecase.execute login_request
    context.put_status(200).json(response)
  end
end
