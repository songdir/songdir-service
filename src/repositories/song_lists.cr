require "repositories"

require "../domain/song_list"

include Repositories::Database

class SongListRepository < DatabaseRepository
  def initialize(database)
    super(database)
    @table = "song_lists"
    @fields[:all] = ["id", "name", "created_at", "user_id"]
  end

  def by_user_id(user_id)
    select_many "user_id=$1", user_id, as: SongList
  end

  def create(id, name, created_at, user_id, songs : Array(String))
    statement = String.build do |str|
      str << build_insert_statement(@table, {"id", "name", "created_at", "user_id"})
      # Add songs
      if !query[:songs].empty?
        str << "INSERT INTO song_in_list"
        str << " (position,song_id,song_list_id)"
        str << " VALUES "
        rows = query[:songs].map_with_index(1) do |song_id, position|
          "(#{position}, '#{song_id}', '#{id}')"
        end
        str << rows.join(",")
      end
    end
    @database.exec statement, id, name, created_at, user_id
  end
end
