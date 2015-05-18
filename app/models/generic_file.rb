class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile

  has_and_belongs_to_many :creators, predicate: ::RDF::DC.creator, class_name: "Agent", inverse_of: :generic_files

  accepts_nested_attributes_for :creators
end
