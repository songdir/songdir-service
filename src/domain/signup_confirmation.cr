require "json"
require "db"

class SignupConfirmation
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : String
  property sent_to : String
  property user_id : Int64
end
