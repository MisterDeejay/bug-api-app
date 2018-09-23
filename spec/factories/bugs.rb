FactoryBot.define do
  factory :bug do
    application_token { SecureRandom.hex(10) }
    number { Faker::Number.number(2) }
    priority { ['minor','major','critical'][rand(0..2)] }
    status { ['new','in-progress','closed'][rand(0..2)] }
  end
end
