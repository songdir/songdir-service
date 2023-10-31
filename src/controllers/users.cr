require "grip"
require "clean-architectures"

require "../requests/users"
require "../responses/users"
require "../services/users"
require "../adapters/gmail"
require "../repositories/users"
require "../utils/get_database"

class SigninController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def post(context : Context) : Context
    signin_request = SigninRequest.from_json get_raw_body(context)
    users_repository = UsersRepository.new(get_database())
    service = SigninService.new(users_repository)
    response = service.call signin_request
    respond_with_either context, response
  end
end

class SignupController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def post(context : Context) : Context
    signup_request = SignupRequest.from_json get_raw_body(context)
    users_repository = UsersRepository.new(get_database())
    gmail_adapter = GmailAdapter.new(CA.config_from_env("GMAIL_API_HOST", "GMAIL_USER_ID", "GMAIL_API_KEY"))
    service = SignupService.new(users_repository, gmail_adapter)
    response = service.call signup_request
    respond_with_either context, response
  end
end

class ConfirmSignupController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def put(context : Context) : Context
    users_repository = UsersRepository.new(get_database())
    service = ConfirmSignupService.new(users_repository)
    code = context.fetch_path_params["code"]
    response = service.call code
    respond_with_either context, response
  end
end