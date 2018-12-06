require 'rails_helper'

RSpec.describe ResponsesController, type: :controller do

  xdescribe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "GET #update" do
    it "returns http success" do
      get :update
      expect(response).to have_http_status(:success)
    end
  end

end
