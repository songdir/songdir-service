require "grip"

class SongListsController < Grip::Controllers::Http
  def get(context : Context) : Context
  end

  def post(context : Context) : Context
  end

  def add_song(context : Context) : Context
  end

  def join(context : Context) : Context
  end
end

class SongListUpdateController < Grip::Controllers::Http
  def put(context : Context) : Context
  end
end

class SongListDestroyController < Grip::Controllers::Http
  def delete(context : Context) : Context
  end
end