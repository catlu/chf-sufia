module NestedDates
  extend ActiveSupport::Concern
  
  module ClassMethods
    def build_permitted_params
      permitted = super
      permitted << { date_of_work_attributes: permitted_time_span_params }
      permitted << { date_of_publication_attributes: permitted_time_span_params }
      permitted
    end

    def permitted_time_span_params
      [ :id, :_destroy, :start, :start_qualifier, :finish, :finish_qualifier, :label, :note ]
    end

  end

  def date_of_work_attributes= attributes
    model.date_of_work_attributes= attributes
  end
  def date_of_publication_attributes= attributes
    model.date_of_publication_attributes= attributes
  end

end
