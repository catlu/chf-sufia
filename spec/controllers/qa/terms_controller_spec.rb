require 'rails_helper'

RSpec.describe Qa::TermsController do
  routes { Qa::Engine.routes }

  describe "local genre vocabulary" do
    it "returns a term" do
      get :search, vocab: 'local', subauthority: 'genres', q: 'pho'
      expect(response).to be_success
    end
  end

end
