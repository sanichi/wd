require 'rails_helper'

describe PgnGame do
  describe "clean" do
    def pgn(headers, moves, nl: "\n", nlh: nil)
      nlh = nl if nlh.nil?
      "[]#{nlh}" * headers + nl + "m#{nl}" * moves
    end

    it "discards any games after the first" do
      expect(PgnGame.clean(pgn(3,8) + "\n" + pgn(7,7))).to eq pgn(3,8)
    end

    it "discards leading and trailing space" do
      expect(PgnGame.clean(" \r\n" + pgn(8,3) + " \r\n")).to eq pgn(8,3)
      expect(PgnGame.clean("\n\r " + pgn(6,1) + "\r\n ")).to eq pgn(6,1)
    end

    it "converts line endings" do
      expect(PgnGame.clean(pgn(9,2, nl: "\r\n"))).to eq pgn(9,2)
      expect(PgnGame.clean(pgn(10,4, nl: "\r"))).to eq pgn(10,4)
    end

    it "canonicalises headers" do
      expect(PgnGame.clean(pgn(9,2, nlh: ""))).to eq pgn(9,2)
      expect(PgnGame.clean(pgn(10,4, nlh: " "))).to eq pgn(10,4)
      expect(PgnGame.clean(pgn(7,1, nlh: "\n\n"))).to eq pgn(7,1)
    end

    it "removes timestamps" do
      expect(PgnGame.clean("1.e4 {[%clk 0:04:59]} c5 {[%clk 0:05:03]} 1/2-1/2")).to eq "1.e4 c5 1/2-1/2"
    end

    it "does not modify a clean file" do
      all_pgn_files.each do |pgn|
        expect(PgnGame.clean(pgn)).to eq pgn
      end
    end
  end
end
