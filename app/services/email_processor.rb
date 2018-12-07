class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process!
    EmailProcessor::TranscriptSaver.new(email).process!

    return unless first_email.present?
    slug = first_email[:token].to_sym

    EmailProcessor::SignUp.new(email, slug: slug).process!
    EmailProcessor::SignedUpChecker.new(email, slug: slug).process!

    EmailProcessor::Status.new(email, slug: slug).process!
    EmailProcessor::Request.new(email, slug: slug).process!

    # Rails.logger.info("Email")
    # Rails.logger.info(email.inspect)
    # Rails.logger.info("As json")
    # Rails.logger.info(email.to_json)
    # Rails.logger.info("To")
    # Rails.logger.info(email.to)
    # Rails.logger.info("From")
    # Rails.logger.info(email.from)
    # Rails.logger.info("CC")
    # Rails.logger.info(email.cc)
    # Rails.logger.info("Subject")
    # Rails.logger.info(email.subject)
    # Rails.logger.info("Body")
    # Rails.logger.info(email.body)
    # Rails.logger.info("Raw text")
    # Rails.logger.info(email.raw_text)
    # Rails.logger.info("Raw html")
    # Rails.logger.info(email.raw_html)
    # Rails.logger.info("Attachments")
    # Rails.logger.info(email.attachments.inspect)
    # Rails.logger.info("Headers")
    # Rails.logger.info(email.headers)
    # Rails.logger.info("Raw Headers")
    # Rails.logger.info(email.raw_headers)
  rescue StopProcessing
    Rails.logger.info("Stopped Processing the rest of the chain")
  end

  private

  attr_reader :email

  def first_email
    email.to.first { |e| e[:email].include? ".approveforme.com" }
  end
end
