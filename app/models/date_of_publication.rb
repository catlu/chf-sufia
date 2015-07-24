class DateOfPublication < TimeSpan
  has_many :generic_files, inverse_of: :date_of_publication, class_name: "GenericFile"
end
