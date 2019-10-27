require 'rails_helper'

describe Game do
  def pgn(headers, moves, nl="\n")
    "h#{nl}" * headers + nl + "m#{nl}" * moves
  end

  let(:data) { build(:game, pgn: file("lee_orr.pgn")) }

  describe "clean" do
    it "detects rubbish" do
      expect(Game.clean(nil)).to be_nil
      expect(Game.clean("")).to be_nil
      expect(Game.clean("rubbish")).to be_nil
    end

    it "picks out only the first game" do
      expect(Game.clean(pgn(7,4) + "\n" + pgn(8,6))).to eq pgn(7,4)
    end

    it "discards leading and trailing space" do
      expect(Game.clean(" \r\n" + pgn(8,3) + " \r\n")).to eq pgn(8,3)
      expect(Game.clean("\n\r " + pgn(6,1) + "\r\n ")).to eq pgn(6,1)
    end

    it "converts line endings" do
      expect(Game.clean(pgn(9,2, "\r\n"))).to eq pgn(9,2)
      expect(Game.clean(pgn(10,4, "\r"))).to eq pgn(10,4)
    end

    it "no change to clean file" do
      expect(Game.clean(data.pgn)).to eq data.pgn
    end
  end
end
