module BugSubmissionError
  class InvalidBugNumber < StandardError
    ERR_MSG = 'Please submit these attributes without a bug number'

    def initialize
      super(ERR_MSG)
    end
  end
end
