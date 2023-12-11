require "grip"

require "./extensions"

class SongListsController < Grip::Controllers::Http
  include Extensions::EitherResponse

  def get(context : Context) : Context
    context.put_status(200)
  end

  def post(context : Context) : Context
    context.put_status(200)
  end

  def add_song(context : Context) : Context
    context.put_status(200)
  end

  def join(context : Context) : Context
    context.put_status(200)
  end
end

class SongListUpdateController < Grip::Controllers::Http
  include Extensions::EitherResponse

  def put(context : Context) : Context
    context.put_status(200)
  end
end

class SongListDestroyController < Grip::Controllers::Http
  include Extensions::EitherResponse

  def delete(context : Context) : Context
    context.put_status(200)
  end
end
