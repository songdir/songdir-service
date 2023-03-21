require "random/secure"

require "../lib/request_objects/user"
require "../lib/exceptions"
require "../lib/auth"
require "../repositories/user"
require "../conf/settings"

class SigninUseCase

  def initialize(@user_repository : UserRepository)
  end

  def execute(request : SigninRequest)
    user = @user_repository.get_by_username request.username
    if user.username.empty?
      raise UnAuthorized.new "Invalid credentials were provided"
    end
    salt = Random::Secure.random_bytes(32)
    password_key = key_derivation PASSWORD_SECRET_KEY, salt
    decrypted_password = decrypt request.password, password_key
    if request.password != decrypted_password
      raise UnAuthorized.new "Invalid credentials were provided"
    end
    {
      "data" => {
        "token" => create_jwt_token(request, JWT_EXPIRATION_MINUTES.to_i32, JWT_SECRET_KEY)
      }
    }
  end
end
