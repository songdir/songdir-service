alias MessageList = Array(String)

alias ErrorMessages = MessageList | Hash(String, MessageList)

DATETIME_ISOFORMAT = "%Y-%m-%dT%H:%M:%S"

class ValidationError < Exception
  property body

  def initialize(@body)
    if @body.is_a?(String)
      @body = {
        "errors" => {
          "non_field_errors" => body
        }
      }
    else
      @body = {
        "errors" => body
      }
    end
  end

  def status : Int32
    400
  end
end


def common_validations(parent_obj : Hash, field_key, required=false, allow_null=true) : MessageList
  messages = [] of String
  if required && !parent_obj.has_key?(field_key)
    messages << "field is required"
  end
  if !allow_null && field_value.nil?
    messages << "must not be null"
  end
  messages
end


def common_string_validations(field_value : String, min_length=Nil, max_length=Nil, allow_blank=true) : MessageList
  messages = [] of String
  if !allow_blank && field_value.empty?
    messages << "must not be blank"
  end
  if !min_length.nil? && field_value.size < min_length
    messages << "length of string is less than #{min_length}"
  end
  if !max_length.nil? && field_value.size > max_length
    messages << "length of string is greater than #{max_length}"
  end
  messages
end


def number_validations(field_value, minimum=Nil, maximum=Nil) : MessageList
  messages = [] of String
  if !minimum.nil? && field_value < minimum
    messages << "value is less than #{minimum}"
  end
  if !maximum.nil? && field_value > maximum
    messages << "value is greater than #{maximum}"
  end
  messages
end


abstract class SerializerField

  def initialize(@required=false, @allow_null=true)
  end

  abstract def serialize
  abstract def deserialize
end


class IntegerField < SerializerField
  def initialize(@minimum=Nil, @maximum=Nil, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, Int32)
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, 0}
    end
    if @allow_null && field_value.nil?
      return {[] of String, 0}
    end
    if field_value.is_a?(String) && /^\d+$/.match(field_value)
      field_value = field_value.to_i
    end
    if !field_value.is_a?(Int32)
      valuetype = typeof(field_value).to_s
      return {["expected integer, but got #{valuetype}"], 0}
    end
    messages.concat(number_validations(field_value, minimum: @minimum, maximum: @maximum))
    if messages
      return {messages, 0}
    end
    {[] of String, field_value}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, Int32) 
    self.serialize(parent_obj, field_key, field_value)
  end
end


class FloatField < SerializerField
  def initialize(@minimum=Nil, @maximum=Nil, @accept_integers=false, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, Float)
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, 0.0}
    end
    if @allow_null && field_value.nil?
      return {[] of String, 0.0}
    end
    if field_value.is_a?(String) && /^\d+$/.match(field_value)
      if /^\d+$/.match(field_value)
        field_value = field_value.to_i
      elsif /^\d+\.\d+$/.match(field_value)
        field_value = field_value.to_f
      end
    end
    valuetype = typeof(field_value).to_s
    if @accept_integers && !field_value.is_a?(Number)
      return {["expected int or float, but got #{valuetype}"], 0.0}
    elsif !@accept_integers && !field_value.is_a?(Float)
      return {["expected float, but got #{valuetype}"], 0.0}
    end
    messages.concat(number_validations(field_value, minimum: @minimum, maximum: @maximum))
    if messages
      return {messages, 0.0}
    end
    {[] of String, field_value}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, Float) 
    self.serialize(parent_obj, field_key, field_value)
  end
end


class BooleanField < SerializerField
  def initialize(@required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, Bool)
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, false}
    end
    if @allow_null && field_value.nil?
      return {[] of String, false}
    end
    if !field_value.is_a?(Bool)
      valuetype = typeof(field_value).to_s
      return {["expected boolean, but got #{valuetype}"], false}
    end
    if messages
      return {messages, false}
    end
    {[] of String, field_value}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, Bool) 
    self.serialize(parent_obj, field_key, field_value)
  end
end


class StringField < SerializerField
  def initialize(@min_length=Nil, @max_length=Nil, @allow_blank=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, String)
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, ""}
    end
    if @allow_null && field_value.nil?
      return {[] of String, ""}
    end
    if !field_value.is_a?(String) && !field_value.nil?
      valuetype = typeof(field_value).to_s
      return {["expected string, but got #{valuetype}"], ""}
    end
    messages.concat(common_string_validations(field_value,
                                              min_length: @min_length,
                                              max_length: @max_length,
                                              allow_blank: @allow_blank))
    if messages
      return {messages, ""}
    end
    {[] of String, field_value}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, String) 
    self.serialize(parent_obj, field_key, field_value)
  end
end


class EmailField < SerializerField
  def initialize(@min_length=Nil, @max_length=Nil, @allow_blank=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, String)
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, ""}
    end
    if @allow_null && field_value.nil?
      return {[] of String, ""}
    end
    if !field_value.is_a?(String)
      valuetype = typeof(field_value).to_s
      return {["expected string, but got #{valuetype}"], ""}
    end
    messages.concat(common_string_validations(field_value,
                                              min_length: @min_length,
                                              max_length: @max_length,
                                              allow_blank: @allow_blank))
    if messages
      return {messages, ""}
    end
    if !/^[a-zA-Z0-9_.-]+@[a-zA-Z0-9_-]+(\.[a-zA-Z_]+)+$/.match(field_value)
      return {["invalid email format '#{field_value}'"], ""}
    end
    {[] of String, field_value}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, String) 
    self.serialize(parent_obj, field_key, field_value)
  end
end


class DatetimeField < SerializerField
  def initialize(@datetime_format=DATETIME_ISOFORMAT, @allow_blank=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, Time | Nil)
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, nil}
    end
    if @allow_null && field_value.nil?
      return {[] of String, nil}
    end
    if !field_value.is_a?(String)
      valuetype = typeof(field_value).to_s
      return {["expected string, but got #{valuetype}"], nil}
    end
    messages.concat(common_string_validations(field_value,
                                              min_length: @min_length,
                                              max_length: @max_length,
                                              allow_blank: @allow_blank))
    if messages
      return {messages, nil}
    end
    parsed_datetime = Nil
    begin
      parsed_datetime = Time.parse(field_value, @datetime_format, Time::Location::UTC)
      {[] of String, parsed_datetime}
    rescue ex
      {["invalid datetime format '#{field_value}'"], nil}
    end
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, Int32 | Nil) 
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, nil}
    end
    if @allow_null && field_value.nil?
      return {[] of String, nil}
    end
    if !field_value.is_a?(Time)
      valuetype = typeof(field_value).to_s
      return {["expected date-time, but got #{valuetype}"], nil}
    end
    {[] of String, field_value.to_s(@datetime_format)}
  end
end


class EnumField < SerializerField
  def initialize(@enum_class, @allow_blank=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, Enum | Nil)
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, nil}
    end
    if @allow_null && field_value.nil?
      return {[] of String, nil}
    end
    if !field_value.is_a?(Int32)
      valuetype = typeof(field_value).to_s
      return {["expected integer, but got #{valuetype}"], nil}
    end
    {[] of String, @enum_class.new(field_value)}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, Int32) 
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
      return {messages, 0}
    end
    if @allow_null && field_value.nil?
      return {[] of String, 0}
    end
    if !field_value.is_a?(Enum)
      valuetype = typeof(field_value).to_s
      return {["expected enum, but got #{valuetype}"], nil}
    end
    {[] of String, field_value.value}
  end
end


class ListField(T) < SerializerField
  def initialize(@child, @allow_empty=true, @required=false, @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  private def serialize_child_elem(field_value, field_key, elem) : Tuple(MessageList, Array(T))
    messages, serialized = @child.serialize(field_value, field_key, elem)
    if messages
      return {messages, [] of T}
    end
    {[] of String, serialized}
  end

  private def deserialize_child_elem(field_value, field_key, elem) : Tuple(MessageList, Array(T))
    messages, serialized = @child.deserialize(field_value, field_key, elem)
    if messages
      return {messages, [] of T}
    end
    {[] of String, serialized}
  end

  private def pre_validations(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
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

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, Array(T))
    messages = self.pre_validations(parent_obj, field_key, field_value)
    if messages
      return {messages, [] of T}
    end
    if @allow_null && field_value.nil?
      return {[] of String, [] of T}
    end
    serialized_child = field_value.map { |elem| self.serialize_child_elem(field_value, field_key, elem) }
    error_messages = serialized_child.reduce([] of String) { |acc, pair| acc.concat(pair[0]) }
    serialized_values = serialized_child.map { |pair| pair[1] }
    if error_messages
      return {error_messages, [] of T}
    end
    {[] of String, serialized_values}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, Array(T))
    messages = self.pre_validations(parent_obj, field_key, field_value)
    if messages
      return {messages, [] of T}
    end
    if @allow_null && field_value.nil?
      return {[] of String, [] of T}
    end
    serialized_child = field_value.map { |elem| self.deserialize_child_elem(field_value, field_key, elem) }
    error_messages = serialized_child.reduce([] of String) { |acc, pair| acc.concat(pair[0]) }
    serialized_values = serialized_child.map { |pair| pair[1] }
    if error_messages
      return {error_messages, [] of T}
    end
    {[] of String, serialized_values}
  end
end


class DictField(K, V) < SerializerField
  def initialize(@value,
                 @key : IntegerField | FloatField | BooleanField | StringField | EmailField | EnumField,
                 @allow_empty=true,
                 @required=false,
                 @allow_null=true)
    super(required: @required, allow_null: @allow_null)
  end

  private def serialize_child_elem(field_value, field_key, key, value) : Tuple(MessageList, Hash(K, V))
    key_messages, serialized_key = @key.serialize(field_value, field_key, key)
    value_messages, serialized_value = @value.serialize(field_value, field_key, value)
    if key_messages || value_messages
      return {key_messages.concat(value_messages), {} of K => V}
    end
    {[] of String, {serialized_key => serialized_value}}
  end

  private def deserialize_child_elem(field_value, field_key, key, value) : Tuple(MessageList, Hash(K, V))
    key_messages, serialized_key = @key.deserialize(field_value, field_key, key)
    value_messages, serialized_value = @value.deserialize(field_value, field_key, value)
    if key_messages || value_messages
      return {key_messages.concat(value_messages), {} of K => V}
    end
    {[] of String, {serialized_key => serialized_value}}
  end

  private def pre_validations(parent_obj, field_key, field_value) : MessageList
    messages = common_validations(parent_obj,
                                  field_key,
                                  field_value,
                                  required=@required,
                                  allow_null=@allow_null)
    if messages
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

  def serialize(parent_obj, field_key, field_value) : Tuple(MessageList, Hash(K, V))
    messages = self.pre_validations(parent_obj, field_key, field_value)
    if messages
      return {messages, {} of K => V}
    end
    if @allow_null && field_value.nil?
      return {[] of String, {} of K => V}
    end
    serialized_pairs = field_value.each do |key, value|
      self.serialize_child_elem(field_value, field_key, key, value)
    end
    error_messages = serialized_child.reduce([] of String) { |acc, pair| acc.concat(pair[0]) }
    serialized_hash = serialized_child.reduce({} of K => V) { |acc, pair| acc.merge(pair[1]) }
    if error_messages
      return {error_messages, {} of K => V}
    end
    {[] of String, serialized_hash}
  end

  def deserialize(parent_obj, field_key, field_value) : Tuple(MessageList, Hask(K, V))
    messages = self.pre_validations(parent_obj, field_key, field_value)
    if messages
      return {messages, {} of K => V}
    end
    if @allow_null && field_value.nil?
      return {[] of String, {} of K => V}
    end
    serialized_pairs = field_value.each do |key, value|
      self.deserialize_child_elem(field_value, field_key, key, value)
    end
    error_messages = serialized_child.reduce([] of String) { |acc, pair| acc.concat(pair[0]) }
    serialized_hash = serialized_child.reduce({} of K => V) { |acc, pair| acc.merge(pair[1]) }
    if error_messages
      return {error_messages, {} of K => V}
    end
    {[] of String, serialized_hash}
  end
end


class Serializer

  def initialize(@input_data, @raise_exception=true)

  end

  def properties
    {{ @type.methods.map(&.name).select { |meth| !meth.includes?("=") }.map(&.stringify) }}
  end
end
