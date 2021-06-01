require 'rails_helper'

describe Layout do
  describe "valid" do
    it "one row, two breakpoints" do
      lo = Layout.new(sm: [2, 3, 3], xx: [1, 2, 3]).to_a
      expect(lo[0]).to eq "col-sm-2 offset-sm-2 col-xxl-1 offset-xxl-3"
      expect(lo[1]).to eq "col-sm-3 offset-sm-0 col-xxl-2 offset-xxl-0"
      expect(lo[2]).to eq "col-sm-3 offset-sm-0 col-xxl-3 offset-xxl-0"
    end

    it "mixed rows, three breakpoints" do
      lo = Layout.new(lg: [[2, 1, 2], [1, 2, 3]], md: [[3, 2, 3], [2, 3, 4]], xs: [[3, 3], [3, 3], [3, 3]]).to_a
      expect(lo[0]).to eq "col-3 offset-3 col-md-3 offset-md-2 col-lg-2 offset-lg-4"
      expect(lo[1]).to eq "col-3 offset-0 col-md-2 offset-md-0 col-lg-1 offset-lg-0"
      expect(lo[2]).to eq "col-3 offset-3 col-md-3 offset-md-0 col-lg-2 offset-lg-0"
      expect(lo[3]).to eq "col-3 offset-0 col-md-2 offset-md-2 col-lg-1 offset-lg-3"
      expect(lo[4]).to eq "col-3 offset-3 col-md-3 offset-md-0 col-lg-2 offset-lg-0"
      expect(lo[5]).to eq "col-3 offset-0 col-md-4 offset-md-0 col-lg-3 offset-lg-0"
    end

    it "mixed rows, no padding" do
      lo = Layout.new(xl: [3, 3, 3, 3], sm: [[6, 6], [6, 6]]).to_a
      expect(lo[0]).to eq "col-sm-6 offset-sm-0 col-xl-3 offset-xl-0"
      expect(lo[1]).to eq "col-sm-6 offset-sm-0 col-xl-3 offset-xl-0"
      expect(lo[2]).to eq "col-sm-6 offset-sm-0 col-xl-3 offset-xl-0"
      expect(lo[3]).to eq "col-sm-6 offset-sm-0 col-xl-3 offset-xl-0"
    end

    it "xxl and xx are equivalent" do
      lo1 = Layout.new(xx: [3, 3, 3, 3]).to_a
      lo2 = Layout.new(xxl: [3, 3, 3, 3]).to_a
      expect(lo1[0]).to eq lo2[0]
      expect(lo1[1]).to eq lo2[1]
      expect(lo1[2]).to eq lo2[2]
      expect(lo1[3]).to eq lo2[3]
    end
  end

  describe "invalid" do
    it "input" do
      expect{Layout.new(nil)}.to raise_error(StandardError, t("layout.error.input"))
    end

    it "keys" do
      expect{Layout.new(yy: [1, 2, 3])}.to raise_error(StandardError, t("layout.error.keys"))
    end

    it "empty" do
      expect{Layout.new(md: [])}.to raise_error(StandardError, t("layout.error.empty"))
    end

    it "width" do
      expect{Layout.new(md: [0, 4])}.to raise_error(StandardError, t("layout.error.width"))
      expect{Layout.new(md: [4, 13])}.to raise_error(StandardError, t("layout.error.width"))
    end

    it "total" do
      expect{Layout.new(md: [5, 5, 5])}.to raise_error(StandardError, t("layout.error.total"))
    end

    it "rows" do
      expect{Layout.new(md: [1, 2, [3, 4]])}.to raise_error(StandardError, t("layout.error.row"))
      expect{Layout.new(md: [[1, 2], "a"])}.to raise_error(StandardError, t("layout.error.row"))
    end

    it "number" do
      expect{Layout.new(md: [1, 2, 3], lg: [1, 2, 3, 4])}.to raise_error(StandardError, t("layout.error.number"))
    end
  end
end
