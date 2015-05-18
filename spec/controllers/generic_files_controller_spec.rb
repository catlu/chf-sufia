require 'rails_helper'

RSpec.describe GenericFilesController do
  routes { Sufia::Engine.routes }
  let(:user) { FactoryGirl.create(:depositor) }
  before { sign_in user }

  it 'uses the overridden presenter' do
    expect(subject.presenter_class).to eq(ResourcePresenter)
  end

  it 'uses the overridden form' do
    expect(subject.edit_form_class).to eq(ResourceEditForm)
  end

  describe "update" do
    let(:generic_file) do
      GenericFile.create do |gf|
        gf.apply_depositor_metadata(user)
      end
    end

    context "when adding a creator" do
      let(:attributes) do
        { 
          title: ['Dragons love tacos'],
          creators_attributes: [
            { first_name: 'Adam', last_name: 'Rubin' },
            { first_name: 'Daniel', last_name: 'Salmieri' }
          ],
          permissions_attributes: [{ type: 'person', name: 'archivist1', access: 'edit'}]
        }
      end

      before { post :update, id: generic_file, generic_file: attributes }
      subject { generic_file.reload }

      it 'creates Agent instances' do
        expect(Agent.count).to eq 2
      end
      it 'has two creators' do
        expect(subject.creators.count).to eq 2
      end

      it 'assigns agents to the creators field' do
        creators = subject.creators
        first_names  = creators.map(&:first_name)
        last_names  = creators.map(&:last_name)
        expect(first_names).to include 'Adam'
        expect(first_names).to include 'Daniel'
        expect(last_names).to include 'Rubin'
        expect(last_names).to include 'Salmieri'
      end

    end
  end
end

