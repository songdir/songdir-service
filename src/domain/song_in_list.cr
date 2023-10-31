require "json"
require "db"

class SongInList
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : Int32
  property position : Int32
  property song_id : String
  property song_list_id : String
  property created_at : Time
end