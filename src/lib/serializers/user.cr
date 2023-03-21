require "../serializers"


class SigninSerializer < Serializer
  @username = StringField.new required: true, allow_null: false, allow_blank: false
  @password = StringField.new required: true, allow_null: false, allow_blank: false
end


class SignupSerializer < Serializer
  @username = StringField.new required: true, allow_null: false, allow_blank: false
  @password = StringField.new required: true, allow_null: false, allow_blank: false
  @role = StringField.new required: true, allow_null: false, allow_blank: false
  @email = StringField.new required: true, allow_null: false, allow_blank: false
  @phone = StringField.new required: true, allow_null: false, allow_blank: false
end
