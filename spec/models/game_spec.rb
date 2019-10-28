require 'rails_helper'

describe Game do
  describe "clean" do
    def pgn(headers, moves, nl="\n")
      "h#{nl}" * headers + nl + "m#{nl}" * moves
    end

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
      %w/lee_orr vaganian_pogonina zaitsev_karpov/.each do |name|
        pgn = file("#{name}.pgn")
        expect(Game.clean(pgn)).to eq pgn
      end
    end
  end
end
