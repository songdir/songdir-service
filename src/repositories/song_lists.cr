require "uuid"
require "repositories"

require "../domain/song"
require "../responses/basic_song"

include Repositories::Database

class SongListRepository < DatabaseRepository
  def initialize(database)
    super(database)
    @table = "song_lists"
    @fields[:all] = ["id", "name", "created_at", "user_id"]
    @fields[:song] = [
      "id",
      "title",
      "subtitle",
      "artist",
      "composer",
      "genre",
      "album",
      "key",
      "tempo",
      "creation_year",
    ]
  end

  def by_user_id(user_id)
    select_many "user_id=$1", user_id, as: SongList
  end

  def get_songs(list_id)
    statement = String.build do |str|
      fields = @fields[:song].map { |fld| "song.#{fld}" }
      str << "SELECT DISTINCT " << fields.join(",")
      str << " FROM song_in_list sil "
      str << "INNER JOIN songs song ON song.id = sil.song_id "
      str << "WHERE sil.song_list_id=$1"
    end
    @database.query_all statement, list_id, as: BasicSongResponse
  end

  def create(request)
    list_id = UUID.random
    insert({
      id: list_id,
      name: request.name,
      user_id: request.user_id,
      created_at: Time.utc
    })
    if !request.songs.empty?
      songs_statement = String.build do |str|
        str << "INSERT INTO song_in_list "
        str << "(position,song_id,song_list_id) "
        str << "VALUES "
        rows = request.songs.map_with_index(1) do |song_id, position|
          "(#{position}, '#{song_id}', '#{list_id}')"
        end
        str << rows.join(",")
      end
      @database.exec songs_statement
    end
    return list_id
  end

  def add_songs(request)
    if request.songs.empty?
      return 0
    end
    list_id = request.list_id.not_nil!
    current_songs_stmt = build_select_statement(
      "song_in_list",
      ["position", "song_id"],
      "song_list_id=$1",
      order_by: "position"
    )
    last_songs = @database.query_all current_songs_stmt, list_id, as: {Int32, String}
    last_song_ids = last_songs.map { |pair| pair[1].as(String) }
    request.songs.select! { |song_id| !last_song_ids.includes?(song_id) }
    last_position = last_songs.last?.try(&.[0]) || 0

    statement = String.build do |str|
      str << "INSERT INTO song_in_list"
      str << " (position,song_id,song_list_id)"
      str << " VALUES "
      rows = request.songs.map_with_index(last_position + 1) do |song_id, position|
        "(#{position}, '#{song_id}', '#{list_id}')"
      end
      str << rows.join(",")
    end
    @database.exec statement
    request.songs.size
  end
end
