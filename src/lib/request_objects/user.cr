class SigninRequest
  property username
  property password
  property role

  def initialize(@username : String, @password : String, @role="")
  end

  def self.from_json(json_obj)
    instance = SigninRequest.allocate
    instance.initialize(username: json_obj["username"].as(String),
                        password: json_obj["password"].as(String))
    role = json_obj["role"]?
    if role
      instance.role = role.as(String)
    end
    instance
  end
end


class SignupRequest
  property username
  property password
  property role
  property email
  property phone
  property is_admin
  property is_active
  property date_joined

  def initialize(@username : String,
                 @password : String,
                 @role : String,
                 @email : String,
                 @phone : String,
                 @is_admin=false,
                 @is_active=true,
                 @date_joined="")
  end

  def self.from_json(json_obj)
    instance = SignupRequest.allocate
    instance.initialize(username: json_obj["username"].as(String),
                        password: json_obj["password"].as(String),
                        role: json_obj["role"].as(String),
                        email: json_obj["email"].as(String),
                        phone: json_obj["phone"].as(String))
    instance
  end
end
