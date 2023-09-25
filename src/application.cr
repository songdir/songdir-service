require "grip"
require "granite"
require "clean_architectures"

require "./pipes/authorization"
require "./controllers/users"
require "./controllers/songs"
require "./controllers/song_lists"

class Application < Grip::Application
  def initialize(environment : String, serve_static : Bool)
    super(environment, serve_static)

    exception Grip::Exceptions::Forbidden, CA::BaseExceptionController
    exception Grip::Exceptions::NotFound,  CA::BaseExceptionController

    pipeline :authorized_api, [
      AuthorizationPipe.new
    ]

    scope "/" do
      post "/signin", SigninController
      post "/signup", SignupController

      scope "/api" do
        pipe_through :authorized_api
        # Songs
        get    "/songs", SongsController
        get    "/song/:id", SongDetailsController
        post   "/song/create", SongsController
        put    "/song/:id", SongUpdateController
        delete "/song/:id/delete", SongDestroyController
        # Song lists
        get    "/lists", SongListsController
        post   "/list/create", SongListsController
        put    "/list/:id", SongListUpdateController
        delete "/list/:id/delete", SongListDestroyController
        post   "/list/:id/add_song", SongListsController, as: :add_song
        get    "/list/:id/join", SongListsController, as: :join
      end
    end
    router.insert(0, Grip::Handlers::Log.new)
    router.insert(2, CA::SerializableErrorHandler.new)
  end

  def host : String
    ENV["HOST"]
  end

  def port : Int32
    ENV["PORT"]
  end
end

Granite::Connections << Granite::Adapter::Pg.new(name: "pg", url: ENV["DATABASE_URL"])

app = Application.new(environment: ENV["ENVIRONMENT"], serve_static: false)
app.run
