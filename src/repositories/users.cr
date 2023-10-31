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

  def user_exists?(**query)
    exists?(@users_table, query)
  end

  def create(query)
    insert(@users_table, query, returning: "id")
  end

  def create_signup_confirmation(query)
    insert(@signup_confirmation_table, query, returning: "id", as: UUID)
  end

  def is_valid_confirmation?(code)
    exists?(@signup_confirmation_table, {id: eq? code})
  end

  def update_confirmation(code, confirmed : Bool)
    update(@signup_confirmation_table, {is_confirmed: confirmed}, {id: eq? code})
  end

  def is_confirmed?(user_id)
    select_one?(@signup_confirmation_table, ["is_confirmed"], {user_id: eq? user_id}, as: Bool)
  end
end