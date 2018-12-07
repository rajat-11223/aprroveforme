class EmailProcessor
  class Status < Base
    triggered_by :status

    def process
      Rails.logger.info "We're processing a Status message"
    end
  end
end
