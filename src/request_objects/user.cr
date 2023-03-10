class LoginRequest
  property username
  property password

  def initialize(@username : String, @password : String)
  end

  def self.from_json(json_obj)
    instance = LoginRequest.allocate
    instance.initialize(username: json_obj["username"].as(String),
                        password: json_obj["password"].as(String))
    instance
  end
end
