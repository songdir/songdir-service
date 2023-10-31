require "json"
require "db"

class UserRole
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : Int32
  property role_id : Int32
  property user_id : Int32
end