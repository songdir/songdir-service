require "json"
require "db"

class SongList
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : String
  property name : String
  property created_at : Time
  property user_id : Int32
end