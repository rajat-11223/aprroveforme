class EmailProcessor
  class TranscriptSaver < Base
    triggered_by :any

    def process
      Rails.logger.debug("Saving email transcript")
      Rails.logger.debug(email.inspect)
    end
  end
end
