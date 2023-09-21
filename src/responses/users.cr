class SignupResponse
  include JSON::Serializable

  property usernme : String
  property email : String

  def initialize(@username, @email)
  end
end