class GenericFileEditForm < GenericFilePresenter
  include HydraEditor::Form
  include HydraEditor::Form::Permissions
  include NestedDates

  attr_accessor :maker

  self.required_fields = [:title, :identifier]

end
