FactoryBot.define do
  factory :user do
    sequence(:handle) { |n| (n-1).divmod(26).map{|i| (65 + i).chr}.join('') }
    password          { Faker::Internet.password(min_length: User::MIN_PASSWORD) }
    role              { User::ALLOWED_ROLES.sample }
    first_name        { %w(Mark Jim Anne Malcolm Colin).sample }
    last_name         { %w(Orr O'Neil McGonigle MacDonald Mcnab).sample }
  end
end
