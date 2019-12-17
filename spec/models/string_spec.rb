require 'rails_helper'

describe String do
  context "use_halves" do
    it "converts decimal halves" do
      expect("0.5-0.5".use_halves).to eq "½-½"
      expect("1.0-0.0".use_halves).to eq "1-0"
      expect("0.0-1.0".use_halves).to eq "0-1"
      expect("4.5-1.5".use_halves).to eq "4½-1½"
      expect("0.5-5.5".use_halves).to eq "½-5½"
      expect("2.0-4.0".use_halves).to eq "2-4"
      expect("64.0-0.0".use_halves).to eq "64-0"
      expect("33.5-30.5".use_halves).to eq "33½-30½"
      expect(" 0.5-0.5 4.5-1.5 2.0-4.0 0.5-5.5 ".use_halves).to eq " ½-½ 4½-1½ 2-4 ½-5½ "
    end

    it "leave odd cases alone" do
      expect("00.5-0.5".use_halves).to eq "00.5-0.5"
      expect("0.5-0.50".use_halves).to eq "0.5-0.50"
      expect("0.5-2.00".use_halves).to eq "0.5-2.00"
      expect("1.0-01.0".use_halves).to eq "1.0-01.0"
      expect("01.0-1.0".use_halves).to eq "01.0-1.0"
    end
  end
end
