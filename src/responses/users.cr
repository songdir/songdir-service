class SignupResponse
  include JSON::Serializable

  property username : String
  property email : String

  def initialize(@username, @email)
  end
end
