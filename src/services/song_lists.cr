require "http/status"
require "clean-architectures"

require "../domain/song_list"
require "../requests/song_lists"
require "../responses/simple_response"
require "../responses/basic_song"
require "../repositories/song_lists"

class GetUserListsService < CA::Service(Int32, Array(SongList))
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
  end

  def execute(request)
    success @lists_repository.by_user_id request
  end
end

class GetSongsOfListService < CA::Service(String, Array(BasicSongResponse))
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
  end

  def execute(request)
    success @lists_repository.get_songs(request)
  end
end

class CreateListService < CA::Service(SongListRequest, String)
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
    request.songs.each do |song_id|
      assert !UUID.parse?(song_id).nil?, "invalid song id #{song_id}", Status::BAD_REQUEST
    end
  end

  def execute(request)
    list_id = @lists_repository.create(request)
    success list_id.to_s
  end
end

class UpdateListService < CA::Service(SongListUpdateRequest, SimpleResponse)
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
  end

  def execute(request)
    @lists_repository.update_model(request.list_id, {
      name: request.name,
      songs: request.songs
    })
    success({
      "id " => request.list_id.not_nil!,
      "updated" => true
    })
  end
end

class DeleteListService < CA::Service(String, SimpleResponse)
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
  end

  def execute(request)
    @lists_repository.delete "id=$1", request
    success({
      "id" => request,
      "deleted" => true
    })
  end
end

class AddSongsToListService < CA::Service(SongListUpdateRequest, SimpleResponse)
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
    request.songs.each do |song_id|
      assert !UUID.parse?(song_id).nil?, "invalid song id #{song_id}", Status::BAD_REQUEST
    end
  end

  def execute(request)
    added_songs = @lists_repository.add_songs(request)
    success({
      "id" => request.list_id.not_nil!,
      "added" => added_songs
    })
  end
end
