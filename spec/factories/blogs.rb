FactoryBot.define do
  factory :blog do
    draft           { [true, false].sample }
    pin             { [true, false].sample }
    story           { Faker::Lorem.paragraphs(number: 3) }
    summary         { Faker::Lorem.paragraph }
    sequence(:slug) { |n| ["slug#{n}", nil, nil].sample }
    tag             { [Blog::TAGS.sample, nil].sample }
    title           { Faker::Lorem.sentence(word_count: 5).truncate(Blog::MAX_TITLE) }
    user            { nil }
  end
end
