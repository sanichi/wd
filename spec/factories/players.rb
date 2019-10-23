FactoryBot.define do
  factory :player do
    contact            { email || phone ? [true, false].sample : false }
    email              { [Faker::Internet.email, nil].sample }
    federation         { ["SCO", "SCO", "SCO", "IRL", "ENG"].sample }
    sequence(:fide_id) { |n| [n, nil].sample }
    fide_rating        { fide_id ? [rand(Player::MAX_RATING)+1, nil].sample : nil }
    first_name         { %w(Mark Jim Anne Malcolm Colin).sample }
    last_name          { %w(Orr O'Neil McGonigle MacDonald Mcnab).sample }
    phone              { [Faker::PhoneNumber.phone_number.gsub(/[(x)]/, "").gsub(/[.-]/, " "), nil].sample }
    roles              { [Player::ROLES.sample] }
    sequence(:sca_id)  { |n| [n, nil].sample }
    sca_rating         { sca_id ? [rand(Player::MAX_RATING)+1, nil].sample : nil }
    title              { [Player::TITLES.sample, nil, nil, nil].sample }
  end
end
