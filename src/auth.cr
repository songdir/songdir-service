require "json"
require "base64"
require "openssl/hmac"
require "clean-architectures"

module Auth
  extend self

  struct JWTHeader
    property alg : String
    property typ : String
    property kid = ""

    def initialize(@alg, @typ, @kid="")
    end

    def self.from_hash(value)
      instance = JWTHeader.allocate
      instance.initialize(
        value["alg"],
        value["typ"],
        value["kid"]? || ""
      )
      instance
    end

    def to_h
      hash = {
        "alg" => @alg,
        "typ" => @typ
      }
      hash["kid"] = @kid unless @kid.empty?
      hash
    end

    def to_json
      to_h.to_json
    end
  end

  struct JWTClaims
    property iat : Int64
    property exp : Int64
    property sub : Int32? = nil
    property iss : String = ""
    property scope : String = ""
    property aud : String = ""

    def initialize(
      @iat,
      @exp,
      @sub = nil,
      @iss = "",
      @scope = "",
      @aud = ""
    )
    end

    def to_h
      hash = {
        "sub" => @sub,
        "iat" => @iat,
        "exp" => @exp
      } of String => Int32 | Int64 | String | Nil
      hash["iss"] = @iss unless @iss.empty?
      hash["scope"] = @scope unless @scope.empty?
      hash["aud"] = @aud unless @aud.empty?
      hash
    end

    def to_json
      to_h.to_json
    end
  end

  enum JWTStatus
    Valid
    Invalid
    Expired
  end

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

  def create_jwt_token(header, body, secret_key)
    header_b64 = Base64.urlsafe_encode header.to_json
    body_b64 = Base64.urlsafe_encode body.to_json
    fragment = "#{header_b64}.#{body_b64}"
    encrypted_value = encrypt fragment, secret_key
    signature = Base64.urlsafe_encode encrypted_value
    "#{fragment}.#{signature}"
  end

  def compare_jwt(token, secret_key)
    components = split_jwt_token token
    if components == {"", "", ""}
      return JWTStatus::Invalid
    end
    header_b64, body_b64, original_signature = components
    body = JSON.parse Base64.decode_string(body_b64)
    fragment = "#{header_b64}.#{body_b64}"

    encrypted_value = encrypt fragment, secret_key
    signature = Base64.urlsafe_encode encrypted_value
    if original_signature != signature
      return JWTStatus::Invalid
    end
    exp_ms = body["exp"].as_i64
    utcnow = Time.utc
    exp_date = Time.unix_ms(exp_ms)
    puts utcnow
    puts exp_date
    if utcnow > exp_date
      return JWTStatus::Expired
    end
    JWTStatus::Valid
  end

  def get_payload(token)
    components = split_jwt_token token
    if components == {"", "", ""}
      return nil
    end
    value = JSON.parse(Base64.decode_string(components[1]))
    JWTClaims.new(
      value["iat"].as_i64,
      value["exp"].as_i64,
      value["sub"]?.try &.as_i,
      (value["iss"]? || "").as String,
      (value["scope"]? || "").as String,
      (value["aud"]? || "").as String
    )
  end
end
