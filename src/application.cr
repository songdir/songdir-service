require "grip"

require "./controllers/user"
require "./lib/middleware/authorization"

class Application < Grip::Application
  def initialize(environment : String, serve_static : Bool)
    super(environment, serve_static)

    pipeline :api, [
      AuthorizationPipe.new
    ]

    scope "/" do
      post "/signin", SigninController
      post "/signup", SignupController

      scope "/api" do
        pipe_through :api
        scope "/v1" do
          
        end
      end
    end

    router.insert(0, Grip::Handlers::Log.new)
  end

  def host : String
    "127.0.0.1"
  end

  def port : Int32
    8000
  end
end

app = Application.new(environment: "development", serve_static: false)
app.run
