require "grip"
require "clean_architectures"

require "../requests/users"
require "../services/users"
require "../adapters/gmail"
require "../repositories/users"

class SigninController < CA::Controller(CA::StatusError, SigninRequest)
  def post(context : Context) : Context
    signin_request = SigninRequest.from_json get_raw_body(context)
    users_repository = UsersRepository.new get_database()
    service = SigninService.new(users_repository)
    response = service.execute signin_request
    response_from_either(response)
  end
end

class SignupController < Grip::Controllers::Http
  def post(context : Context) : Context
    data = context.request.body.not_nil!
    signup_request = SignupRequest.from_json data
    users_repository = UsersRepository.new get_database()
    gmail_adapter = GmailAdapter.from_env("GOOGLE_API_HOST", "GOOGLE_USER_ID", "GOOGLE_API_KEY")
    service = SignupService.new(users_repository, gmail_adapter)
    response = service.execute signup_request
    context.put_status(200).json(response)
  end
end