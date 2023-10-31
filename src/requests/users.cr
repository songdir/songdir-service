require "json"

class SigninRequest
  include JSON::Serializable

  property username : String
  property password : String
end

class SignupRequest
  include JSON::Serializable

  property username : String
  property first_name : String
  property last_name : String
  property password : String
  property email : String
end