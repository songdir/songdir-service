require "mime/multipart"

class MultipartMessage < MIME::Multipart::Builder
  property from : String
  property to : String
  property subject : String

  def initialize(@from = "", @to = "", @subject = "")
    io = IO::Memory.new
    @boundary = MIME::Multipart.generate_boundary
    super(io, @boundary)
    preamble <<-EOM
      Content-Type: multipart/alternative; boundary="#{@boundary}"
      MIME-Version: 1.0
      From: #{@from}
      To: #{@to}
      Subject: #{@subject}
      EOM
  end
end
