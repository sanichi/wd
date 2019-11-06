FactoryBot.define do
  factory :book do
    author    { Faker::Name.name }
    borrowers { [Faker::Name.name, nil].sample }
    category  { Book::CATEGORIES.sample }
    copies    { [1,1,1,1,1,1,1,2,2,3].sample }
    medium    { Book::MEDIA.sample }
    note      { [nil, nil, Faker::Lorem.sentence.truncate(Book::MAX_NOTE)].sample }
    title     { Faker::Lorem.words(number: 3).join(" ") }
    year      { (Book::MIN_YEAR..Date.today.year).to_a.sample }
  end
end
