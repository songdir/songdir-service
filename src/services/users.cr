require "base64"
require "http/status"
require "clean-architectures"

require "../domain/user"
require "../domain/signup_confirmation"
require "../domain/email"
require "../requests/users"
require "../responses/users"
require "../adapters/gmail"
require "../repositories/users"

include HTTP

class SigninService < CA::Service(SigninRequest, String)
  @user : User? = nil

  def initialize(@users_repository : UsersRepository)
  end

  def validate(request)
    @user = @users_repository.get_by? username: request.username
    assert !@user.nil?, "Invalid username or password", Status::BAD_REQUEST
    assert @user.is_active, "User is not enabled to signin", Status::BAD_REQUEST
  end

  def execute(request)
    encrypted_password = encrypt(request.password, ENV["PASSWORD_SECRET_KEY"]? || "")
    password_b64 = Base64.strict_encode encrypted_password
    if password_b64 != @user.not_nil!.password
      return error "Invalid credentials were provided", Status::UNAUTHORIZED
    end
    success create_jwt_token(request.username, (ENV["JWT_EXPIRATION_MINUTES"]? || 30).to_i32, ENV["JWT_SECRET_KEY"]? || "")
  end
end

class SignupService < CA::Service(SignupRequest, SignupResponse)
  def initialize(@users_repository : UsersRepository, @gmail_adapter : GmailAdapter)
  end

  def validate(request)
    assert !@users_repository.exists?(username: request.username), "username was already taken", Status::BAD_REQUEST
    assert !@users_repository.exists?(email: request.email), "email is already registered", Status::BAD_REQUEST
  end

  def execute(request)
    enc_password = Base64.strict_encode encrypt(request.password, ENV["PASSWORD_SECRET_KEY"]? || "")
    user_id = @users_repository.create({
      username: request.username,
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
      from: ENV["GOOGLE_USER_ID"],
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
