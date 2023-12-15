require "json"

class SongListRequest
  include JSON::Serializable

  property name : String
  property songs : Array(String)
  property user_id = -1
end

class SongListUpdateRequest
  include JSON::Serializable

  property list_id : String? = nil
  property name : String? = nil
  property user_id : Int32? = nil
  property songs = [] of String
end
