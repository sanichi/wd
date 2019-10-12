require 'rails_helper'

describe ApplicationHelper do
  context "#center" do
    it "default" do
      expect(helper.center).to eq "col-12"
    end

    it "md/lg/xl" do
      expect(helper.center(xs: 0, md: 8, lg: 6, xl: 4)).to eq "offset-md-2 col-md-8 offset-lg-3 col-lg-6 offset-xl-4 col-xl-4"
    end

    it "xs/sm/md" do
      expect(helper.center(xs: 9, sm: 7, md: 5)).to eq "offset-1 col-9 offset-sm-2 col-sm-7 offset-md-3 col-md-5"
    end
  end
end
