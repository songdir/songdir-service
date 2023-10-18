require "repositories"

require "../domain/user"

include Repositories::Database

class UsersRepository < DatabaseRepository
  def initialize(database)
    super(database)
    @users_table = "users"
    @signup_confirmation_table = "signup_confirmations"
    @user_fields = [
      "id",
      "first_name",
      "last_name",
      "email",
      "password",
      "document_number",
      "document_type",
      "created_at",
      "is_confirmed",
      "is_active"
    ]
  end

  def get_by?(**query)
    select_one?(@users_table, @user_fields, query, as: User)
  end

  def exists?(**query)
    super.exists?(@users_table, query)
  end

  def create(query)
    insert(@users_table, query, returning: "id", as: Int64)
  end

  def create_signup_confirmation(query)
    insert(@signup_confirmation_table, query, returning: "id", as: String)
  end
end