require "json"
require "base64"
require "openssl/hmac"

require "./request_objects/user"
require "./exceptions"


def split_jwt_token(token : String) : Tuple(String, String, String)
  components = token.split "."
  if components.size == 3
    header_b64, body_b64, signature = components
    return {header_b64, body_b64, signature}
  end
  {"", "", ""}
end


def encrypt(data, key)
  OpenSSL::HMAC.digest(:sha256, key, data)
end


def create_jwt_token(request : SigninRequest, expiration_minutes, secret_key)
  header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}"
  utcnow = Time.utc
  expiration_span = Time::Span.new(minutes: expiration_minutes)
  body = {
    "role" => request.role,
    "sub" => request.username,
    "iat" => utcnow.to_unix_ms,
    "exp" => (utcnow + expiration_span).to_unix_ms
  }
  header_b64 = Base64.strict_encode header
  body_b64 = Base64.strict_encode body.to_json
  fragment = "#{header_b64}.#{body_b64}"

  encrypted_value = encrypt fragment, secret_key
  signature = Base64.strict_encode encrypted_value
  "#{fragment}.#{signature}"
end


def is_jwt_valid?(token : String, secret_key : String)
  components = split_jwt_token token
  if components == {"", "", ""}
    return false
  end
  header_b64, original_body, original_signature = components
  body = JSON.parse Base64.decode_string(original_body)
  fragment = "#{header_b64}.#{original_body}"

  encrypted_value = encrypt fragment, secret_key
  signature = Base64.strict_encode encrypted_value
  if original_signature != signature
    return false
  end
  exp_ms = body["exp"].as_i
  utcnow = Time.utc
  exp_date = Time.unix_ms(exp_ms)
  if utcnow > exp_date
    raise LoginTimeout.new "Token expired"
  end
  true
end
