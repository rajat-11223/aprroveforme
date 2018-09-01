class FormSubmissionController < ApplicationController
  skip_authorization_check

  def create
    referer = URI.parse(request.referer)

    puts referer.path
    case referer.path
    when %(/blocked_country)
      GdprCustomer::Log.new(params, request).call
      redirect_to referer.path, notice: "Thank you! We'll be in touch soon."
    else
      raise "Unknown referer: #{referer}"
    end
  end
end
