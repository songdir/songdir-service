require "json"
require "base64"
require "http/status"
require "clean-architectures"

require "../auth"
require "../conf/settings"
require "../domain/user"
require "../domain/email"
require "../requests/users"
require "../responses/users"
require "../repositories/users"

include HTTP

class SigninService < CA::Service(SigninRequest, String)
  @user : User

  def initialize(@users_repository : UsersRepository)
    @user = User.new
  end

  def validate(request)
    user = @users_repository.by_username? request.username
    assert !user.nil?, "Invalid username or password", Status::UNAUTHORIZED
    @user = user.not_nil!
    assert @user.is_active, "User is not enabled to signin", Status::UNAUTHORIZED
    assert @user.is_confirmed?, "You must complete the email confirmation first", Status::UNAUTHORIZED
  end

  def execute(request)
    encrypted_password = encrypt(request.password, PASSWORD_SECRET_KEY)
    password_b64 = Base64.strict_encode encrypted_password
    if password_b64 != @user.password
      return error "Invalid credentials were provided", Status::UNAUTHORIZED
    end
    header = JWTHeader.new(alg: "HS256", typ: "JWT")
    now = Time.utc
    exp = now + Time::Span.new(minutes: JWT_EXPIRATION_MINUTES.to_i)
    body = JWTClaims.new(
      sub: @user.id.not_nil!,
      iat: now.to_unix_ms,
      exp: exp.to_unix_ms
    )
    success create_jwt_token(header, body, JWT_SECRET_KEY)
  end
end

class SignupService < CA::Service(SignupRequest, SignupResponse)
  def initialize(@users_repository : UsersRepository)
  end

  def validate(request)
    user = @users_repository.get?(username: request.username, email: request.email)
    if user.nil?
      return
    end
    if user.not_nil!.username == request.username
      error "username was already taken", Status::BAD_REQUEST
    else
      error "email is already registered", Status::BAD_REQUEST
    end
  end

  def execute(request)
    enc_password = Base64.strict_encode encrypt(request.password, PASSWORD_SECRET_KEY)
    confirmation_token = UUID.random
    now = Time.utc
    @users_repository.create({
      username: request.username,
      first_name: request.first_name,
      last_name: request.last_name,
      email: request.email,
      password: enc_password,
      created_at: now,
      confirmation_token: confirmation_token,
      confirmation_sent_at: now
    })
    # activation_url = "http://localhost:8080/account/activate/#{confirmation_token}"
    # message = MultipartMessage.new(
    #   from: "alvaroczxp@gmail.com",
    #   to: request.email,
    #   subject: "Activación de cuenta Songdir"
    # )
    # text_part = <<-EOM
    #   Por favor activa tu cuenta de Songdir ingresando al siguiente enlace:
    #
    #   #{activation_url}
    #   EOM
    # html_part = <<-HTML
    #   <p>Por favor activa tu cuenta de Songdir ingresando al siguiente enlace:</p>
    #   <hr>
    #   <a href="#{activation_url}">#{activation_url}</a>
    #   HTML
    # message.body_part HTTP::Headers{"Content-Type" => "text/plain"}, text_part
    # message.body_part HTTP::Headers{"Content-Type" => "text/html"}, html_part
    success SignupResponse.new(request.username, request.email)
  end
end

class ConfirmSignupService < CA::Service(String, Hash(String,Bool))
  def initialize(@users_repository : UsersRepository)
  end

  def validate(request)
    confirmed_user = @users_repository.confirm_user request
    if confirmed_user.nil?
      return error "Invalid code", Status::BAD_REQUEST
    end
  end

  def execute(request)
    success({"confirmed" => true})
  end
end
