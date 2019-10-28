require 'rails_helper'

describe Game do
  describe "clean" do
    def pgn(headers, moves, nl: "\n", nlh: nil)
      nlh = nl if nlh.nil?
      "[]#{nlh}" * headers + nl + "m#{nl}" * moves
    end

    it "discards any games after the first" do
      expect(Game.clean(pgn(3,8) + "\n" + pgn(7,7))).to eq pgn(3,8)
    end

    it "discards leading and trailing space" do
      expect(Game.clean(" \r\n" + pgn(8,3) + " \r\n")).to eq pgn(8,3)
      expect(Game.clean("\n\r " + pgn(6,1) + "\r\n ")).to eq pgn(6,1)
    end

    it "converts line endings" do
      expect(Game.clean(pgn(9,2, nl: "\r\n"))).to eq pgn(9,2)
      expect(Game.clean(pgn(10,4, nl: "\r"))).to eq pgn(10,4)
    end

    it "canonicalises headers" do
      expect(Game.clean(pgn(9,2, nlh: ""))).to eq pgn(9,2)
      expect(Game.clean(pgn(10,4, nlh: " "))).to eq pgn(10,4)
      expect(Game.clean(pgn(7,1, nlh: "\n\n"))).to eq pgn(7,1)
    end

    it "no change to clean file" do
      all_pgn_files.each do |pgn|
        expect(Game.clean(pgn)).to eq pgn
      end
    end
  end
end
