class BugsController < ApplicationController
  before_action :set_bug, only: [:show]
  before_action :add_bug_number_to_params, only: [:create]
  before_action only: [:count] { update_bugs_count_cache(application_token) }

  # POST /bugs
  def create
    CreateBugAndStateJob.perform_later(bug_params.to_h, state_params.to_h)
    json_response({ count: cached_bugs_count(application_token) })
  end

  def count
    json_response({ count: cached_bugs_count(application_token) })
  end

  # GET /bugs/:id
  def show
    json_response(@bug.as_json(include: :state))
  end

  private

  def add_bug_number_to_params
    raise ::Exceptions::BugNumberInvalid.new if params['number'].present?
    params['number'] = cached_bugs_count(params[:application_token]).to_i + 1
  end

  def bug_params
    params.permit(:application_token, :priority, :status)
  end

  def state_params
    if params['state'].present?
      params.require(:state).permit(:device, :os, :memory, :storage )
    end
  end

  def set_bug
    @bug = Bug.find_by!(
      number: params[:number],
      application_token: params[:application_token]
    )
  end

  def bug_id
    params.permit(:id, :number)
  end

  def application_token
    params.permit(:application_token)['application_token']
  end
end
