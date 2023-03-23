require "db"
require "json"

require "pg"

class User
  # include JSON::Serializable
  include DB::Serializable

  property username : String
  property password : String
  property id : Int64
  property email : String
  property phone : String
  property is_active : Bool
  property is_confirmed : Bool
  property role_id : Int32
  property date_joined : Time?

  def initialize(
    @username : String,
    @password="",
    @id=0.to_i64,
    @email="",
    @phone="",
    @is_active=true,
    @is_confirmed=false,
    @role_id=0,
    @date_joined : Time?=nil
  )
  end
end
