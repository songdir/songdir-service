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
  property document_number : String = ""
  property document_type : String = ""
  property is_confirmed : Bool = false
  property is_active : Bool = true
end
