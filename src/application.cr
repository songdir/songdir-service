require "pg"
require "grip"

require "./pipes/authorization"
require "./handlers/serializable_error"
require "./controllers/base_exception"
require "./controllers/users"
require "./controllers/songs"
require "./controllers/song_lists"

class Application < Grip::Application
  def initialize(environment : String, serve_static : Bool)
    super(environment, serve_static)

    exception Grip::Exceptions::Forbidden, BaseExceptionController
    exception Grip::Exceptions::NotFound, BaseExceptionController

    pipeline :authorized_api, [
      AuthorizationPipe.new,
    ]

    scope "/" do
      post "/signin", SigninController
      post "/signup", SignupController
      put "/signup/confirm/:code", ConfirmSignupController

      scope "/api" do
        pipe_through :authorized_api
        # Songs
        get "/songs", SongsController
        get "/song/:id", SongDetailsController
        post "/song/create", SongsController
        patch "/song/update", SongUpdateController
        delete "/song/:id/delete", SongDestroyController
        # Song lists
        get "/lists", SongListsController
        post "/list/create", SongListsController
        put "/list/:id", SongListUpdateController
        delete "/list/:id/delete", SongListDestroyController
        post "/list/:id/add_song", SongListsController, as: :add_song
        get "/list/:id/join", SongListsController, as: :join
      end
    end
    router.insert(0, Grip::Handlers::Log.new)
    router.insert(2, SerializableErrorHandler.new)
  end

  def host : String
    ENV["HOST"]
  end

  def port : Int32
    ENV["PORT"].to_i
  end
end

app = Application.new(environment: ENV["ENVIRONMENT"], serve_static: false)
app.run
