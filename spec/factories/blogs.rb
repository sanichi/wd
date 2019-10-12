FactoryBot.define do
  factory :blog do
    draft   { [true, false].sample }
    story   { Faker::Lorem.paragraphs(number: 3) }
    summary { Faker::Lorem.paragraph }
    title   { Faker::Lorem.sentence(word_count: 5).truncate(Blog::MAX_TITLE) }
  end
end
