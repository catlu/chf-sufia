module CHF
  module GenericFile
    module Metadata
      extend ActiveSupport::Concern

      included do

        property :admin_notes, predicate: ::RDF::URI.new("http://chemheritage.org/ns/adminNotes") do |index|
          index.as :stored
        end

        property :genre_string, predicate: ::RDF::URI.new("http://chemheritage.org/ns/hasGenre") do |index|
          index.as :stored_searchable, :facetable
        end

        #Set up a bunch of MARC Relator codes as properties
        Sufia.config.makers.each do |field_name, predicate|
          property field_name, predicate: predicate do |index|
            index.as :stored_searchable
          end
        end

        property :extent, predicate: ::RDF::URI.new("http://chemheritage.org/ns/extent") do |index|
          index.as :stored_searchable
        end

        property :language, predicate: ::RDF::DC11.language do |index|
          index.as :stored_searchable, :facetable
        end
        property :medium, predicate: ::RDF::URI.new("http://chemheritage.org/ns/medium") do |index|
          index.as :stored_searchable
        end
        property :physical_container, predicate: ::RDF::Vocab::Bibframe.materialOrganization, multiple: false do |index|
          index.as :stored_searchable
        end

        property :place_of_interview, predicate: ::RDF::Vocab::MARCRelators.evp do |index|
          index.as :stored_searchable
        end
        property :place_of_manufacture, predicate: ::RDF::Vocab::MARCRelators.mfp do |index|
          index.as :stored_searchable
        end
        property :place_of_publication, predicate: ::RDF::Vocab::MARCRelators.pup do |index|
          index.as :stored_searchable
        end

        property :provenance, predicate: ::RDF::DC.provenance, multiple: false do |index|
          index.as :stored_searchable
        end

        property :resource_type, predicate: ::RDF::DC11.type do |index|
          index.as :stored_searchable, :facetable
        end
        property :rights, predicate: ::RDF::DC11.rights do |index|
          index.as :stored_searchable
        end
        property :rights_holder, predicate: ::RDF::URI.new("http://chemheritage.org/ns/rightsHolder"), multiple: false do |index|
          index.as :stored_searchable
        end

        property :series_arrangement, predicate: ::RDF::Vocab::Bibframe.materialHierarchicalLevel do |index|
          index.as :stored
        end

        property :subject, predicate: ::RDF::DC11.subject do |index|
          index.as :stored_searchable, :facetable
        end

        # TODO: make this work either via linked data or nested attributes
        #  property :genre, predicate: ::RDF::Vocab::EDM.hasType do |index|
        #    index.as :stored_searchable, :facetable
        #  end

        # Class names can be inferred since they are the same as the association name.
        has_many :date_of_work, inverse_of: :is_work_date_of, as: 'is_work_date_of'

        accepts_nested_attributes_for :date_of_work, reject_if: :all_blank, allow_destroy: true


        # Below are copied from sufia
        property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false

        property :depositor, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/relators/dpt"), multiple: false do |index|
          index.as :symbol, :stored_searchable
        end

        property :arkivo_checksum, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#arkivoChecksum'), multiple: false

        property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false

        property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false do |index|
          index.as :symbol
        end

        property :part_of, predicate: ::RDF::DC.isPartOf
        property :title, predicate: ::RDF::DC.title do |index|
          index.as :stored_searchable, :facetable
        end
        property :creator, predicate: ::RDF::DC.creator do |index|
          index.as :stored_searchable, :facetable
        end
        property :description, predicate: ::RDF::DC.description do |index|
          index.type :text
          index.as :stored_searchable
        end
        property :tag, predicate: ::RDF::DC.relation do |index|
          index.as :stored_searchable, :facetable
        end
        property :date_created, predicate: ::RDF::DC.created do |index|
          index.as :stored_searchable
        end

        # We reserve date_uploaded for the original creation date of the record.
        # For example, when migrating data from a fedora3 repo to fedora4,
        # fedora's system created date will reflect the date when the record
        # was created in fedora4, but the date_uploaded will preserve the
        # original creation date from the old repository.
        property :date_uploaded, predicate: ::RDF::DC.dateSubmitted, multiple: false do |index|
          index.type :date
          index.as :stored_sortable
        end

        property :date_modified, predicate: ::RDF::DC.modified, multiple: false do |index|
          index.type :date
          index.as :stored_sortable
        end
        property :identifier, predicate: ::RDF::DC.identifier do |index|
          index.as :stored_searchable
        end
        property :based_near, predicate: ::RDF::FOAF.based_near do |index|
          index.as :stored_searchable, :facetable
        end
        property :related_url, predicate: ::RDF::RDFS.seeAlso do |index|
          index.as :stored_searchable
        end
        property :bibliographic_citation, predicate: ::RDF::DC.bibliographicCitation do |index|
          index.as :stored_searchable
        end
        property :source, predicate: ::RDF::DC.source do |index|
          index.as :stored_searchable
        end

        # TODO: Move this somewhere more appropriate
        begin
          LocalAuthority.register_vocabulary(self, "subject", "lc_subjects")
          LocalAuthority.register_vocabulary(self, "language", "lexvo_languages")
          LocalAuthority.register_vocabulary(self, "tag", "lc_genres")
        rescue
          puts "tables for vocabularies missing"
        end
        type ::RDF::URI.new('http://pcdm.org/models#Object')
      end

    end
  end
end
