class User
  property username
  property password
  property id
  property email
  property phone
  property is_admin
  property is_active
  property date_joined

  def initialize(
    @username : String,
    @password="",
    @id=0.to_i64,
    @email="",
    @phone="",
    @is_admin=false,
    @is_active=true,
    @date_joined : Time?=nil
  )
  end
end
