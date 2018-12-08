class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    EmailProcessor::TranscriptSaver.new(email).process!

    return unless first_email.present?

    EmailProcessor::SignUp.new(email, slug: slug).process!
    EmailProcessor::SignedUpChecker.new(email, slug: slug).process!

    EmailProcessor::Status.new(email, slug: slug).process!
    EmailProcessor::Request.new(email, slug: slug).process!
  rescue StopProcessing => e
    Rails.logger.info("Stopped Processing the rest of the chain")
    Rails.logger.info(e.message)
  end

  private

  attr_reader :email

  def slug
    @slug ||= first_email[:token].to_sym
  end

  def first_email
    @first_email ||= email.to.first { |e| e[:email].include? ".approveforme.com" }
  end
end
