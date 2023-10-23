require "json"
require "db"

class Permission
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : Int64
  property name : String
  property is_active = true
end