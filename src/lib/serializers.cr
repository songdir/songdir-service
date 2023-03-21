require "json"

require "./exceptions"

alias MessageList = Array(String)

alias ErrorMessages = MessageList | Hash(String, MessageList)

alias SerializableNumber = Int32 | Float64 | String | Nil

alias JsonData = Hash(String, Array(JSON::Any) | Bool | Float64 | Hash(String, JSON::Any) | Int64 | String | Nil)

DATETIME_ISOFORMAT = "%Y-%m-%dT%H:%M:%S"


def common_validations(parent_obj,
                       field_key : String,
                       field_value,
                       required=false,
                       allow_null=true) : MessageList
  if required && !parent_obj.has_key?(field_key)
    return ["field is required"]
  end
  if !allow_null && field_value.nil?
    return ["must not be null"]
  end
  [] of String
end


def common_string_validations(field_value : String,
                              min_length : Int32?=nil,
                              max_length : Int32?=nil,
                              allow_blank=true) : MessageList
  if !allow_blank && field_value.empty?
    return ["must not be blank"]
  end
  if !min_length.nil? && field_value.size < min_length
    return ["length of string is less than #{min_length}"]
  end
  if !max_length.nil? && field_value.size > max_length
    return ["length of string is greater than #{max_length}"]
  end
  [] of String
end


def number_validations(field_value : Number,
                       minimum : Number?=nil,
                       maximum : Number?=nil) : MessageList
  if !minimum.nil? && field_value < minimum
    return ["value is less than #{minimum}"]
  end
  if !maximum.nil? && field_value > maximum
    return ["value is greater than #{maximum}"]
  end
  [] of String
end


abstract class SerializerField

  def initialize(@required=false, @allow_null=true)
  end

  abstract def serialize(parent_obj, field_key : String, field_value : JsonData) : MessageList
end


class IntegerField < SerializerField
  def initialize(@minimum : Int32?=nil,
                 @maximum : Int32?=nil,
                 @required=false,
                 @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    if field_value.is_a?(String) && /^\d+$/.match(field_value)
      field_value = field_value.to_i
    end
    if !field_value.is_a?(Int32)
      valuetype = typeof(field_value).to_s
      return ["expected integer, but got #{valuetype}"]
    end
    messages.concat(number_validations(field_value, minimum: @minimum, maximum: @maximum))
  end
end


class FloatField < SerializerField
  def initialize(@minimum : Float64?=nil,
                 @maximum : Float64?=nil,
                 @accept_integers=false,
                 @required=false,
                 @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    valuetype = typeof(field_value).to_s
    if field_value.is_a?(String)
      if /^\d+$/.match(field_value)
        field_value = field_value.to_i
      elsif /^\d+\.\d+$/.match(field_value)
        field_value = field_value.to_f
      else
        return ["expected number, but got #{valuetype}"]
      end
    end
    if @accept_integers && !field_value.is_a?(Number)
      return ["expected int or float, but got #{valuetype}"]
    elsif !@accept_integers && !field_value.is_a?(Float)
      return ["expected float, but got #{valuetype}"]
    end
    messages.concat(number_validations(field_value, minimum: @minimum, maximum: @maximum))
  end
end


class BooleanField < SerializerField
  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    if !field_value.is_a?(Bool)
      valuetype = typeof(field_value).to_s
      return ["expected boolean, but got #{valuetype}"]
    end
    [] of String
  end
end


class StringField < SerializerField
  def initialize(@min_length : Int32?=nil,
                 @max_length : Int32?=nil,
                 @allow_blank=true,
                 @required=false,
                 @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    if !field_value.is_a?(String)
      valuetype = typeof(field_value).to_s
      return ["expected string, but got #{valuetype}"]
    end
    messages.concat(common_string_validations(field_value,
                                              min_length: @min_length,
                                              max_length: @max_length,
                                              allow_blank: @allow_blank))
  end
end


class EmailField < SerializerField
  def initialize(@min_length : Int32?=nil,
                 @max_length : Int32?=nil,
                 @allow_blank=true,
                 @required=false,
                 @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    if !field_value.is_a?(String)
      valuetype = typeof(field_value).to_s
      return ["expected string, but got #{valuetype}"]
    end
    messages.concat(common_string_validations(field_value,
                                              min_length: @min_length,
                                              max_length: @max_length,
                                              allow_blank: @allow_blank))
    if !messages.empty?
      return messages
    end
    if !/^[a-zA-Z0-9_.-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z_]+)+$/.match(field_value)
      return ["invalid email format '#{field_value}'"]
    end
    [] of String
  end
end


class DatetimeField < SerializerField
  def initialize(@datetime_format=DATETIME_ISOFORMAT, @allow_blank=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    if !field_value.is_a?(String)
      valuetype = typeof(field_value).to_s
      return ["expected string, but got #{valuetype}"]
    end
    messages.concat(common_string_validations(field_value,
                                              min_length: @min_length,
                                              max_length: @max_length,
                                              allow_blank: @allow_blank))
    if !messages.empty?
      return messages
    end
    begin
      Time.parse(field_value, @datetime_format, Time::Location::UTC)
      [] of String
    rescue ex
      ["invalid datetime format '#{field_value}'"]
    end
  end
end


class EnumField < SerializerField
  def initialize(@enum_class, @allow_blank=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    if !field_value.is_a?(Int32)
      valuetype = typeof(field_value).to_s
      return ["expected integer, but got #{valuetype}"]
    end
    [] of String
  end
end


class ArrayField(T) < SerializerField
  def initialize(@child, @allow_empty=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  private def pre_validations(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if !field_value.is_a?(Array)
      valuetype = typeof(field_value).to_s
      return ["expected array, but got #{valuetype}"]
    end
    if !@allow_empty && field_value.empty?
      return ["must not be empty"]
    end
    return [] of String
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = self.pre_validations(parent_obj, field_key, field_value)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    field_value.map {|elem| @child.serialize(field_value, field_key, elem) }.flatten
  end
end


class HashField(K, V) < SerializerField
  def initialize(@value : IntegerField | FloatField | BooleanField | StringField,
                 @key : IntegerField | FloatField | BooleanField | StringField | EmailField | EnumField,
                 @allow_empty=true,
                 @required=false,
                 @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  private def pre_validations(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if !messages.empty?
      return messages
    end
    if !field_value.is_a?(Hash)
      valuetype = typeof(field_value).to_s
      return ["expected object, but got #{valuetype}"]
    end
    if !@allow_empty && field_value.empty?
      return ["must not be empty"]
    end
    return [] of String
  end

  private def serialize_child_elem(field_value, field_key, key, value) : MessageList
    key_messages = @key.serialize(field_value, field_key, key)
    value_messages = @value.serialize(field_value, field_key, value)
    key_messages.concat(value_messages)
  end

  def serialize(parent_obj, field_key, field_value) : MessageList
    messages = self.pre_validations(parent_obj, field_key, field_value)
    if !messages.empty?
      return messages
    end
    if @allow_null && field_value.nil?
      return [] of String
    end
    messages = field_value.each do |key, value|
      self.serialize_child_elem(field_value, field_key, key, value)
    end
    messages.flatten
  end
end


alias SerializerFields = IntegerField | FloatField | BooleanField | StringField | EmailField | DatetimeField | EnumField | Serializer

class Serializer
  @errors = {} of String => MessageList

  def initialize(@input_data : JsonData, @raise_exception=true)
    self.serialize_fields
    if @raise_exception && !@errors.empty?
      raise ValidationError.new(@errors)
    end
  end

  def serialize(parent_obj, field_key : String, field_value) : MessageList
    @input_data = field_value
    @errors = {} of String => MessageList
    self.serialize_fields
    if @raise_exception && !@errors.empty?
      raise ValidationError.new(@errors)
    end
    @errors
  end

  private def serialize_fields
    {% for ivar in @type.instance_vars %}
      {% if ivar.type.has_method?(:serialize) %}
        field_key = "{{ivar.id}}"
        field_value = @input_data[field_key]?
        messages = @{{ivar.id}}.serialize(@input_data, field_key, field_value)
        if !messages.empty?
          @errors[field_key] = messages
        end
      {% end %}
    {% end %}
  end
end
