require "grip"

class SongsController < Grip::Controllers::Http
  def get(context : Context) : Context
  end

  def post(context : Context) : Context
  end
end

class SongDetailsController < Grip::Controllers::Http
  def get(context : Context) : Context
  end
end

class SongUpdateController < Grip::Controllers::Http
  def put(context : Context) : Context
  end
end

class SongDestroyController < Grip::Controllers::Http
  def delete(context : Context) : Context
  end
end