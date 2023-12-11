require "json"

class SongRequest
  include JSON::Serializable

  property id = ""
  property title = ""
  property subtitle = ""
  property artist = ""
  property composer = ""
  property genre = ""
  property album = ""
  property key = ""
  property tempo = 0
  property creation_year = 0
  property content = ""
  property content_mimetype = ""
  property user_id = -1

  def initialize(
    id = "",
    title = "",
    subtitle = "",
    artist = "",
    composer = "",
    genre = "",
    album = "",
    key = "",
    tempo = 0,
    creation_year = 0,
    content = "",
    content_mimetype = "",
    user_id = -1,
  )
  end
end

class SongUpdateRequest
  include JSON::Serializable

  property id  : String? = nil
  property title  : String? = nil
  property subtitle  : String? = nil
  property artist  : String? = nil
  property composer  : String? = nil
  property genre  : String? = nil
  property album  : String? = nil
  property key  : String? = nil
  property tempo  : Int32? = nil
  property creation_year  : Int32? = nil
  property content  : String? = nil
  property content_mimetype  : String? = nil
  property updated_at  : Time? = nil

  def initialize(
    id = nil,
    title = nil,
    subtitle = nil,
    artist = nil,
    composer = nil,
    genre = nil,
    album = nil,
    key = nil,
    tempo = nil,
    creation_year = nil,
    content = nil,
    content_mimetype = nil,
    updated_at = nil,
  )
  end
end
