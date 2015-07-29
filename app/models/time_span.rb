class TimeSpan < ActiveFedora::Base
  type ::RDF::Vocab::EDM.TimeSpan

  property :start, predicate: ::RDF::Vocab::EDM.begin, multiple: false
  property :finish, predicate: ::RDF::Vocab::EDM.end, multiple: false
  property :start_qualifier, predicate: ::RDF::Vocab::CRM.P79_beginning_is_qualified_by, multiple: false
  property :finish_qualifier, predicate: ::RDF::Vocab::CRM.P80_end_is_qualified_by, multiple: false
  property :label, predicate: ::RDF::SKOS.prefLabel, multiple: false
  property :note, predicate: ::RDF::SKOS.note, multiple: false

  # DACS date qualifiers
  # http://www2.archivists.org/standards/DACS/part_I/chapter_2/4_date
  BEFORE = "before"
  AFTER = "after"
  CIRCA = "circa"
  DECADE = "decade"
  UNDATED = "Undated"

  START_QUALIFIERS = [BEFORE, AFTER, CIRCA, DECADE, UNDATED]
  END_QUALIFIERS = [BEFORE, CIRCA]

  def self.start_qualifiers
    START_QUALIFIERS
  end

  def self.end_qualifiers
    END_QUALIFIERS
  end

  def range?
    start.present? && finish.present?
  end

  # TODO: this produces 'circa YYYY - circa YYYY'
  # Return a string for display of this record
  def display_label
    if label.present?
      label
    else
      start_string = qualified_date(start, start_qualifier)
      finish_string = qualified_date(finish, finish_qualifier)
      [start_string, finish_string].compact.join(' - ')
    end
  end

  def qualified_date(date, qualifier)
    if qualifier == (BEFORE) || qualifier == (AFTER) || qualifier == (CIRCA)
      "#{qualifier} #{date}"
    elsif qualifier ==  DECADE
      "#{date}s"
    # TODO: If it has a date but also says undated, which do we believe?
    elsif qualifier ==  UNDATED
      qualifier
    elsif date.present?
      date
    else
      nil
    end
  end

  # TODO: Validations
  #  - if start qualifier is 'decade' there should be no end or end qualifier. start should be a year ending '0'.
  #  - if start qualifier is 'undated' there should be no start, end, or end qualifier
  #  - if start qualifier is 'before' there should be no end or end qualifier
  #  - if end exists, start must exist
  #  - if end exists, start < end
  #  - if end exists, legal start qualifiers include:
  #    - (none / exact)
  #    - after
  #    - circa
  #  - legal end qualifiers are:
  #    - (none / exact)
  #    - before
  #    - circa

  #  TODO: solr
  #  note 'decade' is a special case
  # Return an array of years, for faceting in Solr.
  def to_a
    if range?
      (start_integer..finish_integer).to_a
    else
      start_integer
    end
  end

  private
    def start_integer
      extract_year(start)
    end

    def finish_integer
      extract_year(finish)
    end

    def extract_year(date)
      date = date.to_s
      if date.blank?
        nil
      elsif /^\d{4}$/ =~ date
        # Date.iso8601 doesn't support YYYY dates
        date.to_i
      else
        Date.iso8601(date).year
      end
    rescue ArgumentError
      raise "Invalid date: #{date.inspect} in #{self.inspect}"
    end
end
