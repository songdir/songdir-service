require "repositories"

require "../domain/song"

include Repositories::Database

class SongsRepository < DatabaseRepository
  def initialize(database)
    super(database)
    @table = "songs"
    @fields[:all] = [
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
      "content",
      "content_mimetype",
      "created_at",
      "updated_at",
      "user_id"
    ]
  end

  def by_user_id(user_id)
    select_many "user_id=$1", user_id, as: Song
  end
end
