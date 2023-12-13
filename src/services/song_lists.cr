require "http/status"
require "clean-architectures"

require "../domain/song_list"
require "../requests/song_lists"
require "../repositories/song_lists"

alias SimpleStatusResponse = Hash(String, String | Bool)

class GetUserListsService < CA::Service(Int32, Array(SongList))
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
  end

  def execute(request)
    success @lists_repository.by_user_id request
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
    list_id = UUID.random
    @lists_repository.create(
      id: list_id,
      name: request.name,
      created_at: Time.utc,
      user_id: request.user_id,
      songs: request.songs
    )
    success list_id.to_s
  end
end

class UpdateListService < CA::Service(SongListUpdateRequest, SimpleStatusResponse)
  def initialize(@lists_repository : SongListRepository)
  end

  def validate(request)
  end

  def execute(request)
    @lists_repository.update_model(request.id, {
      name: request.name,
      songs: request.songs
    })
    success({
      "id " => request.id,
      "updated" => true
    })
  end
end

class DeleteListService < CA::Service(String, SimpleStatusResponse)
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
