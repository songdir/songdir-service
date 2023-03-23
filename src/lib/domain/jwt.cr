require "json"
require "base64"

class JWTData
  property username
  property role
  property iat
  property exp

  def initialize(@username="",
                 @role="",
                 @iat=0,
                 @exp=0)
  end

  def self.from_base64(value : String)
    instance = JWTData.allocate
    data = JSON.parse Base64.decode_string(value)
    instance.initialize(username: data["username"].as_s,
                        role: data["role"].as_s,
                        iat: data["iat"].as_i,
                        exp: data["exp"].as_i)
    instance
  end
end
