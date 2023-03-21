require "grip"

require "../exceptions"
require "../auth"
require "../../conf/settings"

class AuthorizationPipe
  include HTTP::Handler

  def call(context : HTTP::Server::Context) : HTTP::Server::Context
    auth_header = context.get_req_header "Authorization"
    token = auth_header.split(" ")[1] if auth_header else ""
    if !is_jwt_valid?(token, SECRET_KEY)
      raise UnAuthorized("Invalid authorization token")
    end
  end
end
