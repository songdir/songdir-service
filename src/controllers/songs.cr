require "grip"
require "clean-architectures"

class SongsController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def get(context : Context) : Context
    context.put_status(200)
  end

  def post(context : Context) : Context
    context.put_status(200)
  end
end

class SongDetailsController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def get(context : Context) : Context
    context.put_status(200)
  end
end

class SongUpdateController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def put(context : Context) : Context
    context.put_status(200)
  end
end

class SongDestroyController < Grip::Controllers::Http
  include CA::ControllerExtensions

  def delete(context : Context) : Context
    context.put_status(200)
  end
end
