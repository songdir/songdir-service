require "base64"
require "clean_architectures"

require "../domain/email"
require "../repositories/users"
require "../adapters/gmail"

class SigninUseService
  def initialize(@users_repository : UsersRepository)
  end

  def execute(request : RequestObjects::SigninRequest)
    user = @users_repository.retrieve "users", ["*"], ["username"], request.username, as: Domain::User
    if user.nil?
      raise CA::APIError.simple_message "Invalid username or password"
    end
    user = user.not_nil!
    if !user.is_active
      raise CA::APIError.simple_message "User is not enabled to signin"
    end
    encrypted_password = encrypt(request.password, ENV["PASSWORD_SECRET_KEY"]? || "")
    password_b64 = Base64.strict_encode encrypted_password
    if password_b64 != user.password
      raise CA::APIError.unauthorized "Invalid credentials were provided"
    end
    {
      "data" => {
        "token" => create_jwt_token(request.username, (ENV["JWT_EXPIRATION_MINUTES"]? || 30).to_i32, ENV["JWT_SECRET_KEY"]? || "")
      }
    }
  end
end

class SignupUseCase
  def initialize(@users_repository : UsersRepository,
                 @gmail_adapter : GmailAdapter)
  end

  def execute(request : SignupRequest)
    if @users_repository.exists? "users", ["username"], request.username
      raise CA::APIError.simple_message "username was already taken"
    elsif @users_repository.exists? "users", ["email"], request.email
      raise CA::APIError.simple_message "email is already registered"
    end
    enc_password = Base64.strict_encode encrypt(request.password, ENV["PASSWORD_SECRET_KEY"]? || "")
    user_id = @users_repository.insert(
      "users",
      ["username", "email", "password", "created_at"],
      request.username, request.email, enc_password, Time.utc,
      returning: "user_id"
    )
    confirmation_id = UUID.random()
    activation_url = "http://localhost:8080/account/activate/#{confirmation_id}"
    @users_repository.insert(
      "signup_confirmations",
      ["signup_confirmation_id", "user_id", "sent_to"],
      confirmation_id, user_id, request.email
    )
    message = Email::MultipartMessage.new(
      from:    ENV["GOOGLE_USER_ID"],
      to:      request.email,
      subject: "Activación de cuenta Songdir"
    )
    message.body_part HTTP::Headers{"Content-Type" => "text/plain"}, <<-EOM
      Por favor activa tu cuenta de Songdir haciendo click en el siguiente enlace:

      #{activation_url}
      EOM
    message.body_part HTTP::Headers{"Content-Type" => "text/html"}, <<-EOM
      <p>Por favor activa tu cuenta de Songdir haciendo click en el siguiente enlace:</p>
      <hr>
      <a href="#{activation_url}">#{activation_url}</a>
      EOM
    @gmail_adapter.send message
    {
      "data" => {
        "username" => request.username,
        "email" => request.email
      }
    }
  end
end