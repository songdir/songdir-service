require "grip"

require "./controllers/user"

class Application < Grip::Application
  def initialize(environment : String, serve_static : Bool)
    super(environment, serve_static)

    scope "/api" do
      scope "/v1" do
        post "/login", LoginController
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
