require "repositories"

require "../domain/song"

include Repositories::Database

class SongsRepository < DatabaseRepository
  def initialize(database)
    super(database)
    @table = "songs"
    @song_fields = <<-SQL
      id,
      title,
      subtitle,
      artist,
      composer,
      genre,
      album,
      key,
      tempo,
      creation_year,
      content,
      content_mimetype,
      created_at,
      updated_at,
      user_id
    SQL
    # @fewer_fields = <<-SQL
    #   id,
    #   title,
    #   artist,
    #   user_id
    # SQL
  end

  def by_user_id(user_id)
    statement = "SELECT #{@song_fields} FROM #{@table} WHERE user_id=$1"
    @database.query_all statement, user_id, as: Song
  end

  def create(query)
    keys = query.keys
    statement = String.build do |str|
      str << "INSERT INTO " << @table
      str << '(' << keys.join(",") << ')'
      placeholders = keys.map_with_index(1) { |_, index| placeholder_of(index) }
      str << " VALUES (" << placeholders.join(",") << ')'
    end
    @database.exec statement, *query.values
  end

  def update(id, query)
    statement = String.build do |str|
      str << "UPDATE " << @table << " SET "
      params = query.keys.map_with_index(2) do |key, index|
        "#{key}=COALESCE($#{index}, #{key})"
      end
      str << params.join(",")
      str << " WHERE id=$1"
    end
    @database.exec statement, *{id, *query.values}
  end

  def delete(id)
    statement = "DELETE FROM #{@table} WHERE id=$1"
    @database.exec statement, id
  end
end
