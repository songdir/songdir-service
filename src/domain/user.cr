require "json"
require "db"

class User
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : Int64
  property first_name : String
  property last_name : String
  property email : String
  property password : String
  property created_at : Time
  property document_number = ""
  property document_type = ""
  property is_confirmed = false
  property is_active = true
end
