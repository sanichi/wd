FactoryBot.define do
  factory :user do
    name     { "#{%w(Mark Jim Anne Malcolm Colin).sample} #{%w(Orr O'Neil McGonigle MacDonald Mcnab).sample}" }
    handle   { Faker::Name.initials(number: User::MIN_HANDLE + rand(User::MAX_HANDLE - User::MIN_HANDLE + 1)) }
    password { Faker::Internet.password(min_length: User::MIN_PASSWORD) }
    role     { User::ROLES.sample }
  end
end
