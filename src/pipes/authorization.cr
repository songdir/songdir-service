require "grip"

require "../auth"
require "../conf/settings"

include Auth

class AuthorizationPipe
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    auth_header = context.request.headers.fetch "Authorization", ""
    matched_token = /^#{JWT_TOKEN_NAME} (.+)$/.match(auth_header).try &.[1]
    token = matched_token || ""

    jwt_status = compare_jwt(token, JWT_SECRET_KEY)
    case jwt_status
    when JWTStatus::Invalid
      return respond_with_error context, "Invalid authorization token", HTTP::Status::UNAUTHORIZED
    when JWTStatus::Expired
      return respond_with_error context, "Token has expired", HTTP::Status.new(440)
    end
  end

  private def respond_with_error(context, message, status, content_type="application/json")
    context.response << {"message" => message}.to_json
    context.response.status = status
    context.response.content_type = content_type
    context.response.close
    context
  end
end
