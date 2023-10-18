require "db"
require "pg"

def get_database
  {% if @top_level.has_constant?("DATABASE") %}
    DATABASE
  {% else %}
    DB.open(ENV["DATABASE_URL"])
  {% end %}
end