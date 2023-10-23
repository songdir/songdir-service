require "json"
require "db"

class UserRole
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : Int64
  property role_id : Int64
  property user_id : Int64
end