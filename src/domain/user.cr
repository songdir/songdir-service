require "json"
require "db"

class User
  include DB::Serializable
  include DB::Serializable::NonStrict
  include JSON::Serializable

  property username : String
  property email : String
  property id : Int32? = nil
  property first_name = ""
  property last_name = ""
  property password = ""
  property document_number = ""
  property document_type = ""
  property created_at : Time? = nil
  property confirmed_at : Time? = nil
  property confirmation_sent_at : Time? = nil
  property confirmation_token = ""
  property is_active = true

  def initialize()
    @username = ""
    @email = ""
  end

  def is_confirmed?
    !confirmed_at.nil?
  end
end
