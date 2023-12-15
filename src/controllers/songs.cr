require "grip"

require "./extensions"
require "../services/songs"
require "../repositories/songs"

class SongsController < Grip::Controllers::Http
  include Extensions::JWTAuthentication
  include Extensions::RawBody
  include Extensions::EitherResponse

  def get(context : Context) : Context
    songs_repository = SongsRepository.new(get_database())
    service = GetUserSongsService.new(songs_repository)
    user_id = get_user_id? context
    response = service.call(user_id.not_nil!)
    respond_with_either context, response
  end

  def post(context : Context) : Context
    songs_repository = SongsRepository.new(get_database())
    service = CreateSongService.new(songs_repository)
    song_request = SongRequest.from_json(get_raw_body(context))
    song_request.user_id = get_user_id?(context).as(Int32)
    response = service.call(song_request)
    respond_with_either context, response
  end
end

class SongDetailsController < Grip::Controllers::Http
  include Extensions::EitherResponse

  def get(context : Context) : Context
    context.put_status(200)
  end
end

class SongUpdateController < Grip::Controllers::Http
  include Extensions::RawBody
  include Extensions::EitherResponse

  def patch(context : Context) : Context
    songs_repository = SongsRepository.new(get_database())
    service = UpdateSongService.new(songs_repository)
    song_request = SongUpdateRequest.from_json get_raw_body(context)
    response = service.call(song_request)
    respond_with_either context, response
  end
end

class SongDestroyController < Grip::Controllers::Http
  include Extensions::EitherResponse

  def delete(context : Context) : Context
    songs_repository = SongsRepository.new(get_database())
    service = DeleteSongService.new(songs_repository)
    song_id = context.fetch_path_params["id"]
    response = service.call(song_id)
    respond_with_either context, response
  end
end
