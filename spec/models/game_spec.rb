require 'rails_helper'

describe Game do
  describe "title" do
    it "guesses correctly" do
      {
        lukanin_shmulian:  "Black to play and draw",
        kasas_debarnot:    "Black to play and win",
        zinn_minev:        "Black to play and win",
        zaitsev_karpov:    "Zaitsev-Karpov, Masters-Candidate Masters, 1966, ½-½",
        lee_orr:           "Lee-Orr, Largs Open, 1998, 0-1",
        vaganian_pogonina: "Vaganian-Pogonina, Snowdrops vs Oldhands, 2011, 1-0",
        jansa_marovic:     "White to play and win",
        e_allen:           "White to play and win",
        atakhan_gholami:   "White to play and mate in 2",
        b_h_wood:          "White to play and mate in 4",
      }.each do | name, title |
        expect(Game.create!(pgn: pgn_file("#{name}.pgn")).title).to eq title
      end
    end
  end
end
