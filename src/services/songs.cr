require "uuid"

require "clean-architectures"

require "../domain/song"
require "../requests/songs"
require "../repositories/songs"

alias SimpleStatusResponse = Hash(String, String | Bool)

class GetUserSongsService < CA::Service(Int32, Array(Song))
  def initialize(@songs_repository : SongsRepository)
  end

  def validate(request)
  end

  def execute(request)
    success @songs_repository.by_user_id(request)
  end
end

class CreateSongService < CA::Service(SongRequest, String)
  def initialize(@songs_repository : SongsRepository)
  end

  def validate(request)
  end

  def execute(request)
    now = Time.utc
    song_id = UUID.random
    @songs_repository.create({
      id: song_id,
      title: request.title,
      subtitle: request.subtitle,
      artist: request.artist,
      composer: request.composer,
      genre: request.genre,
      album: request.album,
      key: request.key,
      tempo: request.tempo,
      creation_year: request.creation_year,
      content: request.content,
      content_mimetype: request.content_mimetype,
      created_at: now,
      updated_at: now,
      user_id: request.user_id
    })
    success song_id.to_s
  end
end

class UpdateSongService < CA::Service(SongUpdateRequest, SimpleStatusResponse)
  def initialize(@songs_repository : SongsRepository)
  end

  def validate(request)
  end

  def execute(request)
    @songs_repository.update(request.id, {
      title: request.title,
      subtitle: request.subtitle,
      artist: request.artist,
      composer: request.composer,
      genre: request.genre,
      album: request.album,
      key: request.key,
      tempo: request.tempo,
      creation_year: request.creation_year,
      content: request.content,
      content_mimetype: request.content_mimetype,
      updated_at: Time.utc
    })
    success({
      "id" => request.id.not_nil!,
      "updated" => true
    })
  end
end

class DeleteSongService < CA::Service(String, SimpleStatusResponse)
  def initialize(@songs_repository : SongsRepository)
  end

  def validate(request)
  end

  def execute(request)
    @songs_repository.delete(request)
    success({
      "id" => request,
      "deleted" => true
    })
  end
end
