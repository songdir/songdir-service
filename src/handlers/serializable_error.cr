require "json"

class SerializableErrorHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    call_next(context)
  rescue exc : JSON::SerializableError
    return context if context.response.closed?
    attribute_match = /Missing JSON attribute: (?<field>\w+)/.match(exc.message.not_nil!)
    error_body = {} of String => String?
    if !attribute_match.nil?
      error_body = {
        "message"        => attribute_match.not_nil![0],
        "affected_field" => attribute_match.not_nil!["field"],
      }
    else
      error_body = {
        "message"        => exc.message,
        "affected_field" => exc.attribute,
      }
    end
    context.response << error_body.to_json
    context.response.status = HTTP::Status::BAD_REQUEST
    context.response.content_type = "application/json; charset=UTF-8"
    context
  end
end
