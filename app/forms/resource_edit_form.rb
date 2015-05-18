class ResourceEditForm < ResourcePresenter
  include HydraEditor::Form
  include HydraEditor::Form::Permissions

  self.required_fields = [:title]

  protected
    def self.build_permitted_params
      permitted = super
      permitted.delete({ creators: [] })
      permitted << { creators_attributes: permitted_creators_params }
      permitted
    end

    def self.permitted_creators_params
      [ :id, :_destroy, :first_name, :last_name ]
    end
end
