FactoryBot.define do
  factory :game do
    pgn   { random_pgn_file }
    title { Faker::Lorem.sentence(word_count: 5).truncate(Game::MAX_TITLE) }
    user  nil
  end
end
