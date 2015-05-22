require 'rails_helper'

RSpec.describe BatchEditsController do
  let(:user) { FactoryGirl.create(:depositor) }
  before do
    sign_in user 
    @request.env['HTTP_REFERER'] = 'test.host/original_page'
  end

  it 'uses the overridden terms' do
    expect(subject.terms).to include :creators
  end

  describe "edit form" do
    let(:files) { [] }
    before do
      titles = [
        ['The Runaway Bunny'],
        ['Goodnight Moon']
      ]
      titles.size.times do |i|
        files << GenericFile.new.tap do |f|
          f.title = titles[i]
          f.apply_depositor_metadata(user.user_key)
          f.save!
        end
      end
#      controller.batch = files.map { |f| f.id }
    end

#    it "includes creators, empty" do
#      binding.pry
#      get :edit
#      expect(response).to be_successful
#      expect(assigns[:terms]).to include :creators
#    end
  end


end
