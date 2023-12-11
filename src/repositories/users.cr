require "repositories"

require "../domain/user"

include Repositories::Database

class UsersRepository < DatabaseRepository
  def initialize(database)
    super(database)
    @table = "users"
    @user_fields = <<-SQL
      id,
      first_name,
      last_name,
      username,
      email,
      "password",
      document_number,
      document_type,
      created_at,
      is_active,
      confirmed_at,
      confirmation_token,
      confirmation_sent_at
    SQL
  end

  def by_username?(username)
    statement = <<-SQL
      SELECT #{@user_fields}
      FROM #{@table}
      WHERE username = $1
    SQL
    @database.query_one? statement, username, as: User
  end

  def get?(username="", email="")
    statement = String.build do |str|
      str << <<-SQL
        SELECT #{@user_fields} FROM #{@table}
        WHERE username=$1 OR email=$2
        LIMIT 1
      SQL
    end
    @database.query_one? statement, username, email, as: User
  end

  def create(query)
    keys = query.keys
    statement = String.build do |str|
      str << "INSERT INTO " << @table
      str << '(' << keys.join(",") << ')'
      placeholders = keys.map_with_index(1) { |_, index| placeholder_of(index) }
      str << " VALUES (" << placeholders.join(",") << ')'
      str << " RETURNING id"
    end
    @database.query_one statement, *query.values, &.read(Int32)
  end

  def confirm_user(code)
    statement = <<-SQL
      UPDATE #{@table}
      SET
        confirmed_at=$1,
        confirmation_token=''
      WHERE confirmation_token=$2
      RETURNING id
    SQL
    @database.query_one statement, Time.utc, code, &.read(Int32)
  end
end
