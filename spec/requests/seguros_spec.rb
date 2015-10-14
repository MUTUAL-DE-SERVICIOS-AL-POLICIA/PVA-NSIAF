require 'spec_helper'

RSpec.describe "Seguros", type: :request do
  describe "GET /seguros" do
    it "works! (now write some real specs)" do
      get seguros_path
      expect(response).to have_http_status(200)
    end
  end
end
