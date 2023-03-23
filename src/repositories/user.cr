require "pg"
require "grip"

require "../lib/domain/authentication"
require "../lib/domain/user"
require "../lib/domain/role"
require "../lib/domain/jwt"
require "../lib/request_objects/user"
require "../lib/exceptions"
require "../conf/settings"


class UserRepository
  @auth : Authentication

  def initialize(@auth : Authentication=Authentication.new)
    if !@auth.role.empty?
      role = self.get_role_by_name @auth.role
      if role.name.empty?
        raise UnAuthorized.new "Invalid role"
      end
      @auth.role_id = role.id
    end
  end

  def self.from_jwt_data(data : JWTData)
    auth = Authentication.new(role: data.role,
                              username: data.username,
                              role_id: 0)
    instance = UserRepository.allocate
    instance.initialize(auth)
    instance
  end

  def self.from_grip_context(context : HTTP::Server::Context)
    auth_header = context.get_req_header "Authorization"
    token = /^Token (.+)$/.match(auth_header).not_nil![1]
    _, body, _ = token.split(".")
    jwt_data = JWTData.from_base64(body)
    UserRepository.from_jwt_data jwt_data
  end

  def get_by_username(username : String) : User
    result = DATABASE.query_one? "SELECT username, password FROM users WHERE username=$1;", username, as: {String, String}
    if result
      username, password = result
      return User.new username: username, password: password
    end
    User.new username: ""
  end

  def create(request : SignupRequest) : User
    if @auth.role != "api"
      raise UnAuthorized.new "Not authorized to perform this action"
    end
    fields = "username,password,email,phone,is_active,role_id,date_joined"
    if request.date_joined.empty?
      request.date_joined = Time.utc.to_rfc3339
    end
    role = self.get_role_by_name(request.role)
    if role.name.empty?
      raise ValidationError.new "Invalid role"
    end
    result = DATABASE.exec("INSERT INTO users(#{fields}) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id",
                           request.username,
                           request.password,
                           request.email,
                           request.phone,
                           request.is_active,
                           role.id,
                           request.date_joined)
    date_joined = Time.parse_rfc3339 request.date_joined
    User.new(id: result.last_insert_id,
             username: request.username,
             password: request.password,
             email: request.email,
             phone: request.phone,
             is_active: request.is_active,
             is_confirmed: false,
             role_id: role.id,
             date_joined: date_joined)
  end

  def get_role_by_id(role_id : Int32) : Role
    role = DATABASE.query_one? "SELECT * FROM roles WHERE id=$1", role_id, as: Role
    if role
      return role
    end
    Role.new name: ""
  end

  def get_role_by_name(role_name : String) : Role
    role = DATABASE.query_one? "SELECT * FROM roles WHERE name=$1", role_name, as: Role
    if role
      return role
    end
    Role.new name: ""
  end
end
