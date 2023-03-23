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
    if !user.is_active
      raise UnAuthorized.new "User is inactive"
    end
    role = @user_repository.get_role_by_id user.role_id
    request.role = role.name
    encrypted_password = encrypt request.password, PASSWORD_SECRET_KEY
    password_b64 = Base64.strict_encode encrypted_password
    if password_b64 != user.password
      raise UnAuthorized.new "Invalid credentials were provided"
    end
    {
      "data" => {
        "token" => create_jwt_token(request, JWT_EXPIRATION_MINUTES.to_i32, JWT_SECRET_KEY)
      }
    }
  end
end
