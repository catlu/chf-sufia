require 'rails_helper'

RSpec.describe GenericFile do

  it { is_expected.to respond_to(:creators) }

  describe "adding a creator" do
    let(:gf) do
      GenericFile.create do |f|
        f.apply_depositor_metadata "user"
        f.title = ['This is not my hat']
        f.creators_attributes = [{first_name: "Jon", last_name: "Klassen"}]
      end
    end
    it "gets a creator member of class Agent" do
      expect(gf.creators.count).to eq 1
      expect(gf.creators.first).to be_kind_of Agent
    end
  end
end
