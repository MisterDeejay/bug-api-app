require 'rails_helper'

RSpec.describe Bug, type: :model do
  it { should have_one(:state).dependent(:destroy) }

  it { should validate_presence_of(:application_token) }
  it { should validate_presence_of(:number) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:priority) }
  it { should validate_inclusion_of(:priority).in_array(Bug::VALID_PRIORITIES) }

  describe '.filter_by_application_token' do
    it 'returns the total number of token with the same application token' do
      application_token = SecureRandom.hex(10)
      application_token_2 = SecureRandom.hex(10)
      (0...10).each { |i| FactoryBot.create(:bug, application_token: application_token, number: i) }
      bug = FactoryBot.create(:bug, application_token: application_token_2, number: 1)

      bugs = Bug.filter_by_application_token(application_token)
      expect(bugs.include?(bug)).to be_falsey
      bugs.each do |bug|
        expect(bug.application_token).to eq(application_token)
      end
      expect(bug.application_token).to eq(application_token_2)
    end
  end
end
