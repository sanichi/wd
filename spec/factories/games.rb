FactoryBot.define do
  factory :game do
    pgn   { random_file("*.pgn") }
    title { Faker::Lorem.sentence(word_count: 5).truncate(Game::MAX_TITLE) }
    user  nil
  end
end
