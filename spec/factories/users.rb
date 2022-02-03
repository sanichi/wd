FactoryBot.define do
  factory :user do
    sequence(:handle) { |n| (n-1).divmod(26).map{|i| (65 + i).chr}.join('') }
    password          { Faker::Internet.password(min_length: User::MIN_PASSWORD) }
    roles             { [User::ALLOWED_ROLES.sample] }
    first_name        { %w(Mark Jim Anne Malcolm Colin).sample }
    last_name         { %w(Orr O'Neil McGonigle MacDonald Mcnab).sample }
    otp_required      { false }
    otp_secret        { otp_required ? User::OTP_TEST_SECRET : nil }
    last_otp_at       { otp_required ? 1.send(%w/week day hour/.sample).ago.to_i : nil }
  end
end
