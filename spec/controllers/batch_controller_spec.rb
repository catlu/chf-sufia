require 'rails_helper'

RSpec.describe BatchController do
  routes { Sufia::Engine.routes }
  let(:user) { FactoryGirl.create(:depositor) }
  before { sign_in user }
  let (:batch) {Batch.new}

  it 'uses the overridden form' do
    expect(subject.edit_form_class).to eq(ResourceBatchEditForm)
  end

  describe "update" do
    let(:batch) { Batch.create }
    let(:files) { [] }
    before do
      titles = [
        ['The Runaway Bunny'],
        ['Goodnight Moon']
      ]
      attributes = { creators_attributes: [
          { first_name: 'Margaret Wise', last_name: 'Brown' },
          { first_name: 'Clement', last_name: 'Hurd' }
        ],
      }
      titles.size.times do |i|
        files << GenericFile.new.tap do |f|
          f.title = titles[i]
          f.apply_depositor_metadata(user.user_key)
          f.save!
          f.batch = batch
        end
      end
      batch.generic_files.push files
      post :update, id: batch, 'generic_file' => attributes
      files.size.times { |i| files[i].reload }
    end

    # TODO: how to re-use the same creator objects for each title??
    it 'creates Agent instances' do
      expect(Agent.count).to eq 4
    end

    it "adds creators metadata to multiple files" do
      expect(files[0].creators.size).to eq 2
      expect(files[1].creators.size).to eq 2
    end

    it 'assigns agents to the creators field' do
      creators = files[0].creators
      first_names  = creators.map(&:first_name)
      last_names  = creators.map(&:last_name)
      expect(first_names).to include 'Margaret Wise'
      expect(first_names).to include 'Clement'
      expect(last_names).to include 'Brown'
      expect(last_names).to include 'Hurd'
    end
  end

end
