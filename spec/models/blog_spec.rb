require 'rails_helper'

describe Blog do
  let(:blog1)  { create(:blog, title: " Title1\r\n  ", summary: "Para1\n\n\nPara2\r\n\r\n", story: " ") }
  let(:blog2)  { create(:blog, title: "Long\n\nTitle", summary: "Summary", story: " Para1a\nPara1b\n\nPara2\n\n") }
  let(:blog3)  { create(:blog, title: "Title", summary: "Mark Orr(2200)", story: "Jorge , Blanco") }

  it "normalisation" do
    expect(blog1.title).to eq "Title1"
    expect(blog1.summary).to eq "Para1\n\nPara2"
    expect(blog1.story).to be_nil
    expect(blog2.title).to eq "Long Title"
    expect(blog2.summary).to eq "Summary"
    expect(blog2.story).to eq "Para1a\nPara1b\n\nPara2"
    expect(blog3.summary).to eq "Mark Orr (2200)"
    expect(blog3.story).to eq "Jorge, Blanco"
  end
end
