FactoryBot.define do
  factory :user do
    handle     { Faker::Name.initials(number: User::MIN_HANDLE + rand(User::MAX_HANDLE - User::MIN_HANDLE + 1)) }
    password   { Faker::Internet.password(min_length: User::MIN_PASSWORD) }
    role       { User::ALLOWED_ROLES.sample }
    first_name { %w(Mark Jim Anne Malcolm Colin).sample }
    last_name  { %w(Orr O'Neil McGonigle MacDonald Mcnab).sample }
  end
end
