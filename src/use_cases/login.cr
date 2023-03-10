require "../request_objects/user"
require "../repositories/user"

class LoginUseCase

  def initialize(@user_repository : UserRepository)
  end

  def execute(request : LoginRequest)
    {
      "username" => request.username,
      "password" => request.password
    }
  end
end
