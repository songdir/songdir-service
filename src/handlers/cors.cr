require "../conf/settings"

class CORSHandler
  include HTTP::Handler

  def call(context : HTTP::Server::Context)
    return context if context.response.closed?
    set_cors_headers(context)
    if context.request.method == "OPTIONS"
      context.response.status_code = 200
      context.response.close
    else
      call_next(context)
    end
    context
  end

  def set_cors_headers(context)
    request_origin = context.request.headers["Origin"]?
    is_allowed = match_origin?(request_origin, ALLOWED_ORIGINS)
    context.response.headers["Access-Control-Allow-Origin"] = request_origin.not_nil! if is_allowed
    context.response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    context.response.headers["Access-Control-Allow-Headers"] = "Content-Type,Authorization"
    context.response.headers["Cross-Origin-Opener-Policy"] = "same-origin"
  end

  def match_origin?(origin, allowed_origins)
    if origin.nil?
      return false
    end
    allowed_origins.reduce(true) do |acc, allowed_origin|
      pattern = Regex.new(allowed_origin)
      acc && !pattern.match(origin.not_nil!).nil?
    end
  end
end
