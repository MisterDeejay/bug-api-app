require 'rails_helper'

describe BaseCreator do
  describe "#run" do
    it_behaves_like 'a record creator', 'Bug' do
      let(:valid_attributes) do
        {
          application_token: '1111dd1112',
          number: 1,
          status: 'new',
          priority: 'minor'
        }
      end
      let(:creator) { BaseCreator.new('Bug', valid_attributes) }

      let(:invalid_creator) do
        BaseCreator.new('Bug', { application_token: '1dd1112', number: 1, status: 'new'})
      end
    end
  end
end
