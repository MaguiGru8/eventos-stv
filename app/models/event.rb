class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :kommunity
  belongs_to :user
  belongs_to :event_status

  has_many :event_data_form_entity_groups
  has_many :event_entry_passes
  has_many :event_location_tracks
  has_many :event_locations
  has_many :user_event_locations, :through => :event_locations
  has_many :locations, through: :event_locations
  has_many :comments, as: :commentable
  has_many :event_updates

  has_one_attached :header_image



  after_save :create_log, if: :will_save_change_to_event_status_id?

  before_validation :init


  # scopes
  default_scope { includes(:event_status, :kommunity) }
  scope :with_locations, -> {includes(:locations)}
  scope :with_comments, -> {includes(:comments)}

  ##

  def init
    self.event_status  ||= EventStatus.find_by_name(NameValues::EventStatusType::DRAFT)
  end


  def create_log(current_user = nil)
    current_user = CurrentAccess.user.blank? ? current_user : CurrentAccess.user
    if current_user

      EventStatusLog.create(
                        event: self,
                        user: current_user,
                        event_status: self.event_status
      )

    else
      return "Event Status Change Log Not Created"

    end
  end


  def self.upcoming(kommunity_id: nil)

    if(kommunity_id.blank?)
      return Event.joins(:event_status, :kommunity).where(
                      "event_statuses.name = ? and start_time >= ?",
                      NameValues::EventStatusType::ANNOUNCED, Time.now.beginning_of_day
      ).order("start_time asc")
    else
      return Event.joins(:event_status).where(
          "event_statuses.name = ? and kommunity_id = ? and start_time >= ?",
          NameValues::EventStatusType::ANNOUNCED, kommunity_id, Time.now.beginning_of_day
      ).order("start_time asc")
    end

  end

  def self.recent_past(kommunity_id: nil, count: 5)
    if kommunity_id.blank?
      return Event.joins(:event_status, :kommunity).where(
          "event_statuses.name = ? and start_time <= ?",
          NameValues::EventStatusType::COMPLETED, Time.now.end_of_day
      ).order("start_time desc").limit(count)
    else
      return Event.joins(:event_status).where(
          "event_statuses.name = ? and kommunity_id = ? and start_time <= ?",
          NameValues::EventStatusType::COMPLETED, kommunity_id, Time.now.end_of_day
      ).order("start_time desc").limit(count)
    end
  end


  def status? (event_status_names)
    return event_status_names.include? self.event_status.name
  end

  # change this function to permitted forms
  # send if a user has already filled a form along with the list of permitted forms
  def open_forms

    open_forms = []
    self.event_data_form_entity_groups.each do |edfeg|
      edfeg.data_form_entities.each do |dfe|
        # show only visible forms
        if (dfe.can_fill_event_form(CurrentAccess.user) && !dfe.open_but_invisible?)
          open_forms << dfe
        end
      end
    end

    open_forms

  end


  def start_time
    self[:start_time].blank? ? Time.now : self[:start_time].in_time_zone(self.timezone)
  end


  def end_time
    self[:end_time].blank? ? Time.now : self[:end_time].in_time_zone(self.timezone)
  end



  # list of all data form entity response groups which have been confirmed
  def confirmed_speaker_registrations

    DataFormEntityResponseGroup.joins(:user, :registration_status, event_data_form_entity_group: [:registration_type, :event]).where(
        "events.id = ? and registration_types.name = ? and registration_statuses.name = ?",
        self.id, NameValues::RegistrationsType::SPEAKER, NameValues::RegistrationStatusType::CONFIRMED
    )

  end


  def get_available_speakers
    DataFormEntityResponseGroup.includes(:user).joins(:registration_status, event_data_form_entity_group: [:event, :registration_type]).where('events.id = ? and registration_types.name = ? and registration_statuses.name = ?', self.id, NameValues::RegistrationsType::SPEAKER, NameValues::RegistrationStatusType::CONFIRMED)
  end



  # this method should go to the resque_worker
  def send_feedback_emails(form_id, subject, message, force = false)

    self.event_entry_passes.includes(:event).where(attendance: true).each do |eep|

      if (force || eep.fixed_email_sent?(NameValues::FixedEmailType::FEEDBACK)[0] == false)
        Resque.enqueue(FeedbackMailerWorker, eep.id, form_id, subject, message)
      end

    end


  end

  # sort alphabetically by the name of the speakers
  def public_resources
    return SpeakerResource.joins(data_form_entity_response_group: [:user, {event_data_form_entity_group: :event}]).where('events.id = ?', self.id).order('lower(users.name)')
  end


  # TODO add photos link
  # def get_photos
  #   album_id = 'AF1QipNohy1dAsIrw9zq8KBr6_3dODJwIf38v5Bwj47hRivWtUGKkp4bI1EGi-_5H3C41w'
  #   response = RestClient.post(
  #       'https://photoslibrary.googleapis.com/v1/mediaItems:search',
  #       {albumId: album_id},
  #       headers={
  #           'Authorization': "Bearer #{ENV["STV_GOOGLE_CLIENT_ID"]}"
  #       }
  #   )
  # end



end
