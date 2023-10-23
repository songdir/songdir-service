require "json"
require "db"

class RolePermission
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : Int64
  property role_id : Int64
  property permission_id : Int64
end