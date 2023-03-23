require "db"

require "pg"


class Role
  include DB::Serializable

  property id
  property name

  def initialize(@name : String, @id=0)
  end
end
