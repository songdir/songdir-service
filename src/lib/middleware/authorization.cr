require "grip"

require "../exceptions"
require "../auth"
require "../../conf/settings"

class AuthorizationPipe
  include HTTP::Handler

  def call(context : HTTP::Server::Context) : HTTP::Server::Context
    auth_header = context.request.headers.fetch "Authorization", ""
    token = /^Token (.+)$/.match(auth_header).not_nil![1]?
    token = "" if token.nil?
    if !is_jwt_valid?(token, JWT_SECRET_KEY)
      raise UnAuthorized.new "Invalid authorization token"
    end
    context
  end
end
