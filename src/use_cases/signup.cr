require "base64"

require "../lib/request_objects/user"
require "../lib/exceptions"
require "../lib/auth"
require "../repositories/user"
require "../conf/settings"

class SignupUseCase

  def initialize(@user_repository : UserRepository)
  end

  def execute(request : SignupRequest)
    request.password = Base64.strict_encode encrypt(request.password, PASSWORD_SECRET_KEY)
    request.is_active = ENABLE_EMAIL_CONFIRMATION == "false"
    user = @user_repository.create request
    {
      "data" => {
        "username" => user.username,
        "email" => user.email
      }
    }
  end
end
