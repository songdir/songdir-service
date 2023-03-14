require "../lib/serializers"


class LoginSerializer < Serializer
  @username = StringField.new required: true, allow_null: false
  @password = StringField.new required: true, allow_null: false
end
