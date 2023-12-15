require "json"
require "db"

class BasicSongResponse
  include DB::Serializable
  include JSON::Serializable

  property id = ""
  property title : String
  property subtitle = ""
  property artist : String
  property composer = ""
  property genre : String
  property album = ""
  property key = ""
  property tempo = 0
  property creation_year : Int32
end
