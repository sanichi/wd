FactoryBot.define do
  factory :blog do
    draft          { [true, false].sample }
    pin            { [true, false].sample }
    story          { Faker::Lorem.paragraphs(number: 3) }
    summary        { Faker::Lorem.paragraph }
    sequence(:tag) { |n| [(n-1).divmod(26).map{|i| (97 + i).chr}.join(''), nil, nil].sample }
    title          { Faker::Lorem.sentence(word_count: 5).truncate(Blog::MAX_TITLE) }
    user           { nil }
  end
end
