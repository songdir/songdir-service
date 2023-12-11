require "../auth"
require "../conf/settings"

module Extensions
  module RawBody
    def get_raw_body(context)
      context.request.body.not_nil!
    end
  end

  module JWTAuthentication
    def get_user_id?(context)
      auth_header = context.request.headers.fetch "Authorization", ""
      matched_token = /^#{JWT_TOKEN_NAME} (.+)$/.match(auth_header).try &.[1]
      token = matched_token || ""
      Auth.get_payload(token).try &.sub
    end
  end

  module EitherResponse
    def respond_with_either(context, either)
      if either.right?
        value = either.right
        context.put_status(200)
          .put_resp_header("Content-Type", "application/json; charset=UTF-8")
          .send_resp("{\"data\": #{value.to_json}}")
      else
        error = either.left
        context.put_status(error.not_nil!.status_code)
          .put_resp_header("Content-Type", "application/json; charset=UTF-8")
          .send_resp(error.to_json)
      end
      context
    end
  end
end
