require "json"

class SongListRequest
  include JSON::Serializable

  property name : String
  property user_id : Int32
  property songs : Array(String)
end

class SongListUpdateRequest
  include JSON::Serializable

  property name : String? = nil
  property user_id : Int32? = nil
  property songs = [] of String
end
