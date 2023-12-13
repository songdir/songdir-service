require "repositories"

require "../domain/user"

include Repositories::Database

class UsersRepository < DatabaseRepository
  def initialize(database)
    super(database)
    @table = "users"
    @fields[:all] = [
      "id",
      "first_name",
      "last_name",
      "username",
      "email",
      "password",
      "document_number",
      "document_type",
      "created_at",
      "is_active",
      "confirmed_at",
      "confirmation_token",
      "confirmation_sent_at"
    ]
  end

  def by_username?(username)
    select_one? "username=$1", username, as: User
  end

  def by_username_or_email?(username="", email="")
    select_one? "username=$1 OR email=$2", username, email, as: User
  end

  def confirm_user(code)
    update(
      {
        confirmed_at: Time.utc,
        confirmation_token: ""
      },
      "confirmation_token=$3",
      code,
      returning: "id"
    )
  end
end
