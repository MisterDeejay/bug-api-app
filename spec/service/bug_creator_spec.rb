require 'rails_helper'

describe BugCreator do
  describe "#run" do
    it_behaves_like 'a record creator', 'Bug' do
      let(:valid_attributes) {{ application_token: '1111dd1112',
        number: 1,
        status: 'new',
        priority: 'minor'}}
      let(:creator) { BugCreator.new(params: valid_attributes)}

      let(:invalid_creator) { BugCreator.new(params: {
        number: 1,
        status: 'new',
        priority: 'minor' }) }
    end
  end
end
