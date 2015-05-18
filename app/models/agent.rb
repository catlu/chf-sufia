class Agent < ActiveFedora::Base
  type ::RDF::FOAF.Person

  # chf TODO: remove predicate when upgrading to AF 9.1.1
  # https://github.com/projecthydra/active_fedora/issues/760
  has_many :generic_files, inverse_of: :creators, class_name: "GenericFile", predicate: ::RDF::DC.creator

  property :first_name, predicate: ::RDF::FOAF.firstName, multiple: false do |index|
    index.as :stored_searchable
  end

  property :last_name, predicate: ::RDF::FOAF.lastName, multiple: false do |index|
    index.as :stored_searchable
  end
end
