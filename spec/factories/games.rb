FactoryBot.define do
  factory :game do
    pgn { (Rails.root + "spec" + "files" + ["lee_orr.pgn"].sample).read }
    user nil
  end
end
