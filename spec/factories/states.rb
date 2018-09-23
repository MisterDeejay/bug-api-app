FactoryBot.define do
  factory :todo do
    device { Faker::Device.model_name }
    os { Faker::Device.platform }
    memory { Faker::Number.number(4) }
    created_by { Faker::Number.number(5) }
  end
end
