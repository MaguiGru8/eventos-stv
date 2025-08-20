class EventDataFormEntityGroupsController < ApplicationController
  # before_action :set_kommunity
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_event_data_form_entity_group, only: [:assign_data_form_entity, :destroy, :update_registration_status_counter]
  before_action :access_allowed?



  def create

    if(@event.event_data_form_entity_groups.where(name: event_data_form_entity_groups_controller_params[:name]).blank?)
      @edfeg = EventDataFormEntityGroup.new(event_data_form_entity_groups_controller_params)
      @edfeg.event = @event
      @edfeg.user = current_user
      @edfeg.save
    else
      return error_response(ErrorNotification::ResponseTypes::JS, ErrorNotification::ErrorCodes::CONFLICT, "Los nombres de los conjuntos de formularios deben ser únicos")
    end
  end


  def destroy
  #   check if any responses are present in the EventDataFormEntityGroup
    existing_responses = DataFormEntityResponse.joins(:data_form_entity).where(
        "data_form_entities.entity_id = ? and data_form_entities.entity_type = ?",
        @edfeg, EventDataFormEntityGroup
    )

    if(!existing_responses.blank?)
      return error_response(ErrorNotification::ResponseTypes::JS, ErrorNotification::ErrorCodes::UNAUTHORIZED, "No se puede eliminar porque tiene respuestas.")
    end

    @edfeg_id = @edfeg.id
    @edfeg.destroy
  end


  def assign_data_form_entity
    data_form = DataForm.find_by(id: params[:data_form_id], kommunity_id: @event.kommunity_id)

    if data_form
      # if event already has a data form, then don't add, else add that data form, this just a safety measure to prevent duplicacy
      if @edfeg.data_form_entities.where(data_form: data_form).blank?
        @dfe = DataFormEntity.new(entity: @edfeg, data_form: data_form, name: data_form.name)
        @dfe.save
      else
        return error_response(ErrorNotification::ResponseTypes::JS, ErrorNotification::ErrorCodes::CONFLICT, "Este formulario ya está agregado al evento.")
      end



    end


  end


  # method to update the counter for a specific event data form entity group
  # this will return a script to the browser which will updated the counter every time this route is called
  def update_registration_status_counter
    @selected_status = params[:selected_status_id]
  end



  private

  def set_event
    @event = Event.includes(:user, event_data_form_entity_groups: {data_form_entities: :data_form}).find_by(slug: params[:id], kommunity_id: @kommunity.id)
    RolePermission.event = @event
  end

  def set_event_data_form_entity_group
    @edfeg = EventDataFormEntityGroup.find(params[:event_data_form_entity_group_id])
  end

  def event_data_form_entity_groups_controller_params

    params.require(:event_data_form_entity_group).permit(:name, :registration_type_id)
  end


end