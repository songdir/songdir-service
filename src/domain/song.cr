require "json"
require "db"

class Song
  include DB::Serializable
  include DB::Serializable::NonStrict
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
  property content : String
  property content_mimetype : String
  property created_at : Time
  property updated_at : Time? = nil
  property user_id : Int32

  def initialize(
    @title,
    @artist,
    @genre,
    @creation_year,
    @content,
    @content_mimetype,
    @created_at,
    @user_id,
    @id = "",
    @subtitle = "",
    @composer = "",
    @album = "",
    @key = "",
    @tempo = 0,
    @updated_at = nil
  )
  end
end
