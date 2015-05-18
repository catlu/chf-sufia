class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior

  self.edit_form_class = ResourceEditForm
  self.presenter_class = ResourcePresenter
end
