require 'rails_helper'

RSpec.describe State, type: :model do
  it { should belong_to(:bug) }

  it { should validate_presence_of(:device) }
  it { should validate_presence_of(:os) }
  it { should validate_presence_of(:memory) }
  it { should validate_presence_of(:storage) }
end
