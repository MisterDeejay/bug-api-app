class CreateBugAndStateJob < ApplicationJob
  include BugCache
  queue_as :default

  def perform(bug_params, state_params)
    Bug.transaction do
      @bug = BugCreator.new(params: bug_params).run
      @state = StateCreator.new(bug: @bug, params: state_params).run
    end
  end
end
