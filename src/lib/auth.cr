require "json"
require "base64"
require "random/secure"
require "openssl/pkcs5"
require "openssl/cipher"

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


def key_derivation(password, salt)
  OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 100_000, OpenSSL::Algorithm::SHA256, 32)
end


def encrypt(data, key)
  iv = Random::Secure.random_bytes(32)
  cipher = OpenSSL::Cipher.new("aes-256-cbc")
  cipher.encrypt
  cipher.key = key
  cipher.iv = iv
  
  io = IO::Memory.new
  io.write(iv)
  io.write(cipher.update(data))
  io.write(cipher.final)
  io.rewind

  io.to_slice
end


def decrypt(data, key)
  data_bytes = data.to_slice
  cipher = OpenSSL::Cipher.new("aes-256-cbc")
  cipher.decrypt
  cipher.key = key
  cipher.iv = data_bytes[0, 32]
  data_bytes += 32

  io = IO::Memory.new
  io.write(cipher.update(data_bytes))
  io.write(cipher.final)
  io.rewind

  io.gets_to_end
end


def create_jwt_token(request : SigninRequest, expiration_minutes, secret_key)
  header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}"
  utcnow = Time.utc
  expiration_span = Time::Span.new(minutes: expiration_minutes)
  body = {
    "username" => request.username,
    "role" => request.role,
    "iat" => utcnow.to_unix_ms,
    "exp" => (utcnow + expiration_span).to_unix_ms
  }
  header_b64 = Base64.encode header
  body_b64 = Base64.encode body.to_json
  fragment = "#{header_b64}.#{body_b64}"

  salt = Random::Secure.random_bytes(32)
  key = key_derivation secret_key, salt
  encrypted_value = encrypt fragment, key
  signature = Base64.encode encrypted_value
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

  salt = Random::Secure.random_bytes(32)
  key = key_derivation secret_key, salt
  encrypted_value = encrypt fragment, key
  signature = Base64.encode encrypted_value
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
