require "json"
require "db"

class Song
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property id : String
  property title : String
  property subtitle : String
  property artist : String
  property composer : String
  property genre : String
  property album : String
  property key : String
  property tempo : Int32
  property creation_year : Int32
  property content : String
  property content_mimetype : String
  property created_at : Time
  property updated_at : Time
  property user_id : Int64
end