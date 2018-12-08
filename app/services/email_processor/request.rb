class EmailProcessor
  class Request < Base
    triggered_by :any

    def process
      Rails.logger.info "We're processing a request with a request type!!!"
    end
  end
end
