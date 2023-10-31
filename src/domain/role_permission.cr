require "json"
require "db"

class RolePermission
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : Int32
  property role_id : Int32
  property permission_id : Int32
end