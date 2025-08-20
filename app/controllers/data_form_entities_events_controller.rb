class DataFormEntitiesEventsController < EventsController
  # before_action :set_kommunity
  before_action :authenticate_user!
  before_action :set_event, only: [:remove_data_form_entity]
  before_action :access_allowed?



  def remove_data_form_entity

    @dfe = DataFormEntity.find_by(id: params[:entity_id])

    if (!@dfe.blank? && @dfe.data_form_entity_responses.length == 0)
      @dfe.destroy

    else


      return error_response(
          ErrorNotification::ResponseTypes::JS,
          ErrorNotification::ErrorCodes::INVALID_INPUT,
          "No se puede eliminar, tiene respuestas de formulario adjuntas."
      )
    end


  end


  def update_visibility
    @dfe = DataFormEntity.find(params[:data_form_entity])
    @dfe.update(visibility: params[:visibility])
  end





  private

  def set_data_form_entity
    @dfe = DataFormEntity.find_by(slug: params[:entity_id], entity: @event)
  end


end
