class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    EmailProcessor::TranscriptSaver.new(email).process!

    return unless first_email.present?
    slug = first_email[:token].to_sym

    EmailProcessor::SignUp.new(email, slug: slug).process!
    EmailProcessor::SignedUpChecker.new(email, slug: slug).process!

    EmailProcessor::Status.new(email, slug: slug).process!
    EmailProcessor::Request.new(email, slug: slug).process!
  rescue StopProcessing
    Rails.logger.info("Stopped Processing the rest of the chain")
  end

  private

  attr_reader :email

  def first_email
    email.to.first { |e| e[:email].include? ".approveforme.com" }
  end
end
