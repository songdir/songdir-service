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
    response = service.execute signin_request
    respond_with_either context, response
  end
end

class SignupController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def post(context : Context) : Context
    signup_request = SignupRequest.from_json get_raw_body(context)
    users_repository = UsersRepository.new(get_database())
    gmail_adapter = GmailAdapter.new(CA.config_from_env("GOOGLE_API_HOST", "GOOGLE_USER_ID", "GOOGLE_API_KEY"))
    service = SignupService.new(users_repository, gmail_adapter)
    response = service.execute signup_request
    respond_with_either context, response
  end
end
