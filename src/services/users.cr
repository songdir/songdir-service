require "base64"
require "http/status"
require "clean_architectures"

require "../domain/email"
require "../requests/users"
require "../responses/users"
require "../repositories/users"
require "../adapters/gmail"

class SigninUseService < CA::Service(SigninRequest, String)
  def initialize(@users_repository : UsersRepository)
    @user = nil
  end

  def validate(request)
  end

  def execute(request)
    user = @users_repository.retrieve "users", ["*"], ["username"], request.username, as: Domain::User
    if user.nil?
      return error "Invalid username or password", HTTP::Status::BAD_REQUEST
    end
    user = user.not_nil!
    if !user.is_active
      return error "User is not enabled to signin", HTTP::Status::BAD_REQUEST
    end
    encrypted_password = encrypt(request.password, ENV["PASSWORD_SECRET_KEY"]? || "")
    password_b64 = Base64.strict_encode encrypted_password
    if password_b64 != user.password
      return error "Invalid credentials were provided", HTTP::Status::UNAUTHORIZED
    end
    success create_jwt_token(request.username, (ENV["JWT_EXPIRATION_MINUTES"]? || 30).to_i32, ENV["JWT_SECRET_KEY"]? || "")
  end
end

class SignupUseCase < CA::Service(SignupRequest, SignupResponse)
  def initialize(@users_repository : UsersRepository, @gmail_adapter : GmailAdapter)
  end

  def execute(request)
    if @users_repository.exists? "users", ["username"], request.username
      return error "username was already taken", HTTP::Status::BAD_REQUEST
    elsif @users_repository.exists? "users", ["email"], request.email
      return error "email is already registered", HTTP::Status::BAD_REQUEST
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
    success SignupResponse.new(request.username, request.email)
  end
end