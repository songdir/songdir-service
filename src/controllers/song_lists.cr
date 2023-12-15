require "grip"

require "../requests/song_lists"
require "../services/song_lists"
require "../repositories/song_lists"
require "./extensions"

class SongListsController < Grip::Controllers::Http
  include Extensions::RawBody
  include Extensions::JWTAuthentication
  include Extensions::EitherResponse

  def get(context)
    lists_repository = SongListRepository.new(get_database())
    service = GetUserListsService.new(lists_repository)
    user_id = get_user_id?(context).as(Int32)
    response = service.call(user_id)
    respond_with_either context, response
  end

  def post(context)
    lists_repository = SongListRepository.new(get_database())
    service = CreateListService.new(lists_repository)
    list_request = SongListRequest.from_json(get_raw_body(context))
    list_request.user_id = get_user_id?(context).as(Int32)
    response = service.call(list_request)
    respond_with_either context, response
  end

  def add_songs(context)
    lists_repository = SongListRepository.new(get_database())
    service = AddSongsToListService.new(lists_repository)
    list_request = SongListUpdateRequest.from_json(get_raw_body(context))
    list_request.list_id = context.fetch_path_params["id"]
    response = service.call(list_request)
    respond_with_either context, response
  end

  def join(context)
    context.put_status(200)
  end
end

class SongsOfListController < Grip::Controllers::Http
  include Extensions::EitherResponse

  def get(context)
    lists_repository = SongListRepository.new(get_database())
    service = GetSongsOfListService.new(lists_repository)
    list_id = context.fetch_path_params["id"]
    response = service.call(list_id)
    respond_with_either context, response
  end
end

class SongListUpdateController < Grip::Controllers::Http
  include Extensions::RawBody
  include Extensions::EitherResponse

  def patch(context)
    lists_repository = SongListRepository.new(get_database())
    service = UpdateListService.new(lists_repository)
    list_request = SongListUpdateRequest.from_json(get_raw_body(context))
    response = service.call(list_request)
    respond_with_either context, response
  end
end

class SongListDestroyController < Grip::Controllers::Http
  include Extensions::EitherResponse

  def delete(context)
    lists_repository = SongListRepository.new(get_database())
    service = DeleteListService.new(lists_repository)
    list_id = context.fetch_path_params["id"]
    response = service.call(list_id)
    respond_with_either context, response
  end
end
