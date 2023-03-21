class User
  def initialize(
    @username : String,
    @password="",
    @id=0,
    @email="",
    @phone="",
    @is_admin=false,
    @is_active=true,
    @date_joined : Time?=nil
  )
  end
end
