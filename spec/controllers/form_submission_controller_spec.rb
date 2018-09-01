require 'rails_helper'

RSpec.describe FormSubmissionController, type: :controller do

  describe "#create will create a GDPR customer" do
    it "returns http success" do
      expect(GdprCustomer.count).to eq(0)

      request.headers.merge!({ 'HTTP_REFERER' => 'http://example.com/blocked_country' })
      post :create

      expect(response).to have_http_status(:redirect)
      expect(GdprCustomer.count).to eq(1)
    end
  end

end
