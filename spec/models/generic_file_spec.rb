require 'rails_helper'

RSpec.describe GenericFile do
  MyFields = {
    # overriden fields
    contributor: 'http://purl.org/dc/elements/1.1/contributor',
    language: 'http://purl.org/dc/elements/1.1/language',
    publisher: 'http://purl.org/dc/elements/1.1/publisher',
    resource_type: 'http://purl.org/dc/elements/1.1/type',
    rights: 'http://purl.org/dc/elements/1.1/rights',
    subject: 'http://purl.org/dc/elements/1.1/subject',
    # new fields
    creator_of_work: 'http://purl.org/dc/elements/1.1/creator',
    admin_notes: 'http://chemheritage.org/ns/adminNotes',
    division: 'http://chemheritage.org/ns/division',
    artist: 'http://id.loc.gov/vocabulary/relators/art',
    author: 'http://id.loc.gov/vocabulary/relators/aut',
    file_creator: 'http://www.ebu.ch/metadata/ontologies/ebucore/ebucore#hasCreator',
    interviewee: 'http://id.loc.gov/vocabulary/relators/ive',
    interviewer: 'http://id.loc.gov/vocabulary/relators/ivr',
    manufacturer: 'http://id.loc.gov/vocabulary/relators/mfr',
    photographer: 'http://id.loc.gov/vocabulary/relators/pht',
    extent: 'http://chemheritage.org/ns/extent',
    medium: 'http://chemheritage.org/ns/medium',
    physical_container: 'http://bibframe.org/vocab/materialOrganization',
    place_of_interview: 'http://id.loc.gov/vocabulary/relators/evp',
    place_of_manufacture: 'http://id.loc.gov/vocabulary/relators/mfp',
    place_of_publication: 'http://id.loc.gov/vocabulary/relators/pup',
    provenance: 'http://purl.org/dc/terms/provenance',
    rights_holder: 'http://chemheritage.org/ns/rightsHolder',
    series_arrangement: 'http://bibframe.org/vocab/materialHierarchicalLevel',
  }

  it 'uses a different predicate for each field' do
    f = GenericFile.new
    predicates = f.resource.fields.map do |attr|
      GenericFile.reflect_on_property(attr).predicate.to_s
    end
    dup = predicates.select{ |element| predicates.count(element) > 1 }
    expect(dup).to be_empty
  end

  it 'uses the right predicate for new and overriden fields' do
    MyFields.each do |field_name, uri|
      predicate = GenericFile.reflect_on_property(field_name).predicate.to_s
      expect(predicate).to eq uri
    end
  end

  describe 'Correctly populates fields' do
    let :generic_file do
      GenericFile.create(title: ['title1']) do |gf|
        gf.apply_depositor_metadata('dpt')
        gf.creator = ['Beckett, Samuel']
        gf.extent = ["infinitely long"]
      end
    end

    it 'has a single creator' do
      expect(generic_file.creator.count).to eq 1
      expect(generic_file.creator).to include 'Beckett, Samuel'
    end

    it 'has a toc' do
      expect(generic_file.extent).to eq ["infinitely long"]
    end

    describe "add a Date Range", focus: true do
      before do
        binding.pry
        generic_file.date_of_work_attributes = [{start: "2003", finish: "2015"}]
      end
      it "uses TimeSpan class" do
        expect(generic_file.date_of_work.first).to be_kind_of TimeSpan
      end
    end

#    describe "retrieve a Date Range" do
#      it "finds the nested attributes" do
#        generic_file.date_of_work_attributes = [ { start: "2003" }, { start: "2996" } ]
#        generic_file.save!
#        expect(GenericFile.find(generic_file.id).date_of_work.count).to eq 2 #returns both
#        expect(GenericFile.load_instance_from_solr(generic_file.id).date_of_work.count).to eq 2 #returns both
#      end
#    end
#
  end

#  describe "#date_of_work_attributes" do
#    let(:attributes) do
#      [{
#        start: '2003',
#        finish: '2015'
#      }]
#    end
#
#    it "should be able to delete items" do
#      g = described_class.new
#      g.date_of_work_attributes = attributes
#      g.save!(:validate => false)
#      g.date_of_work_attributes = [
#        {
#          :id => g.date_of_work.first.id,
#          :_destroy => true
#        },
#        { :start => "1999" }
#      ]
#      
#      g.save!(:validate => false)
#      g.reload
#
#      expect(g.date_of_work.length).to eq 1
#      expect(g.date_of_work.first.start).to eq ["1999"]
#    end
#    it "should work on already persisted items" do
#      g = described_class.new.tap{|x| x.save(:validate => false)}
#      g.nested_authors_attributes = attributes
#
#      g.save!(:validate => false)
#      g.reload
#
#      expect(g.nested_authors.first.name).to eq ["Bob"]
#    end
#    it "should be able to edit" do
#      g = described_class.new
#      g.nested_authors_attributes = attributes
#      g.save!(:validate => false)
#      g.nested_authors_attributes = {
#        "0" => {
#          :id => g.nested_authors.first.id,
#          :name => "Banana"
#        }
#      }
#      
#      g.save!(:validate => false)
#      g.reload
#
#      expect(g.nested_authors.length).to eq 1
#      expect(g.nested_authors.first.name).to eq ["Banana"]
#    end
#    it "should not create blank ones" do
#      g = described_class.new
#      g.nested_authors_attributes = {
#        "0" => {
#          :name => "",
#          :orcid => ""
#        }
#      }
#      expect(g.nested_authors.length).to eq 0
#    end
#  end
#  it "should be able to create nested authors" do
#    g = described_class.new
#    g.nested_authors_attributes = [{:name => "Bob", :orcid => "Test"}]
#    g.save!(:validate => false)
#
#    g.reload
#
#    expect(g.nested_authors.first.name).to eq ["Bob"]
#    expect(g.nested_authors.first.orcid).to eq ["Test"]
#    expect(g.nested_authors.first.new_record?).to eq false
#  end
#  it "should be able to create multiple nested authors" do
#    g = described_class.new
#    g.nested_authors_attributes = {
#      "0" => {
#        "name" => "1"
#      },
#      "1" => {
#        "name" => "2"
#      }
#    }
#
#    g.save!(:validate => false)
#    g.reload
#
#    expect(g.nested_authors.length).to eq 2
#    expect(g.nested_authors.map{|x| x.name.first}).to contain_exactly("1","2")
#  end
#  describe "#attributes=" do
#    it "accepts nested attributes" do
#      g = described_class.new
#      g.attributes = {
#        :nested_authors_attributes => [
#          {
#            :name => "Bob",
#            :orcid => "Test"
#          }
#        ]
#      }
#
#      g.save!(:validate => false)
#      g.reload
#
#      expect(g.nested_authors.first.name).to eq ["Bob"]
#    end
  #end
end
