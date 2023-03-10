require "grip"

require "../request_objects/user"
require "../use_cases/login"
require "../repositories/user"

class LoginController < Grip::Controllers::Http
  def post(context : Context) : Context
    user_repository = UserRepository.new
    usecase = LoginUseCase.new(user_repository: user_repository)
    login_request = LoginRequest.from_json context.fetch_json_params
    response = usecase.execute(login_request)
    context.put_status(200)
      .json(response)
  end
end
