class StateCreator < BaseCreator
  INVALID_BUG_MESSAGE = 'Bug must be present for state creation'

  def initialize(bug:, params:)
    @bug = bug
    super('State', params)
  end

  def run
    super do
      record.bug = @bug
    end
  end
end
