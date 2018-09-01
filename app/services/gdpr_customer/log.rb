class GdprCustomer
  class Log
    def initialize(params, request)
      @params = params
      @request = request
    end

    def call
      email = params[:email] || ""
      search = params[:search] || ""
      country = request.headers["HTTP_CF_IPCOUNTRY"] || "eu-unknown"

      GdprCustomer.create! email: email.downcase,
                           search: search.downcase,
                           country: country.downcase
    end

    private

    attr_reader :params, :request

  end
end
