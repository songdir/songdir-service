require "base64"
require "random/secure"

require "../lib/request_objects/user"
require "../lib/exceptions"
require "../lib/auth"
require "../repositories/user"
require "../conf/settings"

class SignupUseCase

  def initialize(@user_repository : UserRepository)
  end

  def execute(request : SignupRequest)
    salt = Random::Secure.random_bytes(32)
    password_key = key_derivation PASSWORD_SECRET_KEY, salt
    request.password = Base64.encode encrypt(request.password, password_key)
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
