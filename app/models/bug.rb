class Bug < ApplicationRecord
  VALID_PRIORITIES = %w( minor major critical )
  include AASM
  include BugCache
  has_one :state, dependent: :destroy
  after_save { |bug| update_bugs_count_cache(bug.application_token) }

  validates_presence_of :application_token, :number, :status, :priority
  validates_inclusion_of :priority, :in => VALID_PRIORITIES
  scope :filter_by_application_token, lambda{ |token| where(application_token: token) }
  scope :count_by_application_token, lambda{ |token| filter_by_application_token(token).count }
  scope :latest, lambda{ order(:created_at).last }

  aasm do
    state :new, initial: true
    state :in_progress
    state :closed

    event :progress do
      transitions from: :new, to: :in_progress
    end

    event :close do
      transitions from: :in_progress, to: :closed
    end
  end
end
