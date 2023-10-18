require "base64"
require "clean-architectures"

require "../domain/email"

class GmailAdapter < CA::Adapter
  def initialize(@config)
    super(@config, name: "Gmail", description: "Gmail adapter to send automatic emails")
    @host = @config["GMAIL_API_HOST"].as(String)
    @user_id = @config["GMAIL_USER_ID"].as(String)
    @api_key = @config["GMAIL_API_KEY"].as(String)
  end

  def send(message : MultipartMessage)
    encoded_message = Base64.strict_encode message.to_s
    body = {
      "message" => {
        "raw" => encoded_message,
      }
    }
    response = HTTP::Client.post(
      "#{@host}/v1/users/#{@user_id}/messages/send?key=#{@api_key}",
      headers: HTTP::Headers{"Content-TYpe" => "application/json"},
      body: body.to_json
    )
  end
end
