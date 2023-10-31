require "base64"
require "http/status"
require "clean-architectures"
require "repositories/database/sql_functions"

require "../domain/user"
require "../domain/signup_confirmation"
require "../domain/email"
require "../requests/users"
require "../responses/users"
require "../adapters/gmail"
require "../repositories/users"

include HTTP

class SigninService < CA::Service(SigninRequest, String)
  @user : User

  def initialize(@users_repository : UsersRepository)
    @user = User.new
  end

  def validate(request)
    user = @users_repository.get_by? username: eq? request.username
    assert !user.nil?, "Invalid username or password", Status::UNAUTHORIZED
    @user = user.not_nil!
    assert @user.is_active, "User is not enabled to signin", Status::UNAUTHORIZED
    is_confirmed = @users_repository.is_confirmed? @user.id
    assert is_confirmed, "You must complete the email confirmation first", Status::UNAUTHORIZED
  end

  def execute(request)
    encrypted_password = encrypt(request.password, ENV["PASSWORD_SECRET_KEY"]? || "")
    password_b64 = Base64.strict_encode encrypted_password
    if password_b64 != @user.password
      return error "Invalid credentials were provided", Status::UNAUTHORIZED
    end
    success create_jwt_token(request.username, (ENV["JWT_EXPIRATION_MINUTES"]? || 30).to_i32, ENV["JWT_SECRET_KEY"]? || "")
  end
end

class SignupService < CA::Service(SignupRequest, SignupResponse)
  def initialize(@users_repository : UsersRepository, @gmail_adapter : GmailAdapter)
  end

  def validate(request)
    assert !@users_repository.user_exists?(username: eq? request.username), "username was already taken", Status::BAD_REQUEST
    assert !@users_repository.user_exists?(email: eq? request.email), "email is already registered", Status::BAD_REQUEST
  end

  def execute(request)
    enc_password = Base64.strict_encode encrypt(request.password, ENV["PASSWORD_SECRET_KEY"]? || "")
    user_id = @users_repository.create({
      username: request.username,
      first_name: request.first_name,
      last_name: request.last_name,
      email: request.email,
      password: enc_password,
      created_at: Time.utc
    })
    user_id = user_id.not_nil!
    confirmation_id = UUID.random
    activation_url = "http://localhost:8080/account/activate/#{confirmation_id}"
    @users_repository.create_signup_confirmation({
      id: confirmation_id,
      sent_to: request.email,
      user_id: user_id
    })
    message = MultipartMessage.new(
      from: ENV["GMAIL_USER_ID"],
      to: request.email,
      subject: "Activación de cuenta Songdir"
    )
    text_part = <<-EOM
      Por favor activa tu cuenta de Songdir ingresando al siguiente enlace:

      #{activation_url}
      EOM
    html_part = <<-HTML
      <p>Por favor activa tu cuenta de Songdir ingresando al siguiente enlace:</p>
      <hr>
      <a href="#{activation_url}">#{activation_url}</a>
      HTML
    message.body_part HTTP::Headers{"Content-Type" => "text/plain"}, text_part
    message.body_part HTTP::Headers{"Content-Type" => "text/html"}, html_part
    @gmail_adapter.send message
    success SignupResponse.new(request.username, request.email)
  end
end

class ConfirmSignupService < CA::Service(String, Hash(String,Bool))
  def initialize(@users_repository : UsersRepository)
  end

  def validate(request)
    valid_code = @users_repository.is_valid_confirmation? request
    assert valid_code, "Invalid code", Status::BAD_REQUEST
  end

  def execute(request)
    @users_repository.update_confirmation request, confirmed: true
    success({"confirmed" => true})
  end
end