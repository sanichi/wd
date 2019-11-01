require 'rails_helper'

describe Game do
  describe "title" do
    it "guesses correctly" do
      {
        lee_orr:           "Lee, C. - Orr, M., Largs Open, 1998, 0-1",
        zaitsev_karpov:    "Igor Zaitsev - Anatoly Karpov, Masters-Candidate Masters, 196...",
        vaganian_pogonina: "Vaganian,R - Pogonina,N, Snowdrops vs Oldhands, 2011, 1-0",
        b_h_wood:          "White to play and mate in 4",
        e_allen:           "White to play and win",
      }.each do | name, title |
        expect(Game.create!(pgn: pgn_file("#{name}.pgn")).title).to eq title
      end
    end
  end
end
