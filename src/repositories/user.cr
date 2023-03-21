require "grip"

require "../lib/domain/user"
require "../lib/request_objects/user"
require "../conf/settings"

class UserRepository
  def get_by_username(username) : User
    result = DATABASE.query_one? "SELECT (username,password) FROM users WHERE username=$1", username, as: NamedTuple
    if result
      username, password = result
      User.new username: username, password: password
    end
    User.new username: ""
  end

  def create(request : SignupRequest) : User
    fields = "username,password,email,phone,is_admin,is_active,date_joined"
    if request.date_joined.empty?
      request.date_joined = Time.utc.to_rfc3339
    end
    result = DATABASE.exec("INSERT INTO users(#{fields}) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING id",
                           request.username,
                           request.password,
                           request.email,
                           request.phone,
                           request.is_admin,
                           request.is_active,
                           request.date_joined)
    date_joined = Time.parse_rfc3339 request.date_joined
    User.new(id: result.last_insert_id,
             username: request.username,
             password: request.password,
             email: request.email,
             phone: request.phone,
             is_admin: request.is_admin,
             is_active: request.is_active,
             date_joined: date_joined)
  end
end
