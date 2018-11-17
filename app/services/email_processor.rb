class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    # EmailProcessor::TranscriptSaver.new(email).process
    # EmailProcessor::SignedUpCheker.new(email).process
    #
    # slug = email.to[:status].token.to_sym
    # case slug
    # when :signup, :sign_up
    #   EmailProcessor::SignUp.new(email, slug: :signup).process
    # when :status
    #   EmailProcessor::Status.new(email, slug: :status).process
    # else
    Rails.logger.info("Email")
    Rails.logger.info(email.inspect)
    Rails.logger.info("As json")
    Rails.logger.info(email.to_json)
    Rails.logger.info("To")
    Rails.logger.info(email.to)
    Rails.logger.info("From")
    Rails.logger.info(email.from)
    Rails.logger.info("CC")
    Rails.logger.info(email.cc)
    Rails.logger.info("Subject")
    Rails.logger.info(email.subject)
    Rails.logger.info("Body")
    Rails.logger.info(email.body)
    Rails.logger.info("Raw text")
    Rails.logger.info(email.raw_text)
    Rails.logger.info("Raw html")
    Rails.logger.info(email.raw_html)
    Rails.logger.info("Attachments")
    Rails.logger.info(email.attachments.inspect)
    Rails.logger.info("Headers")
    Rails.logger.info(email.headers)
    Rails.logger.info("Raw Headers")
    Rails.logger.info(email.raw_headers)
    # end
  end

  private

  attr_reader :email
end
