require "base64"
require "clean_architectures"

class GmailAdapter < CA::Service
  def initialize(@config)
    super.initialize(@config, name: "Gmail", description: "Gmail adapter to send automatic emails")
    @host = @config["GMAIL_API_HOST"] # https://gmail.googleapis.com/upload/gmail
    @user_id = @config["GMAIL_USER_ID"]
    @api_key = @config["GMAIL_API_KEY"]
  end

  def send(message : Email::MultipartMessage)
    encoded_message = Base64.strict_encode message.to_s
    body = {
      "message" => {
        "raw" => encoded_message
      }
    }
    response = HTTP::Client.post(
      "#{@host}/v1/users/#{@user_id}/messages/send?key=#{@api_key}",
      headers: HTTP::Headers{"Content-TYpe" => "application/json"},
      body: body
    )
  end
end