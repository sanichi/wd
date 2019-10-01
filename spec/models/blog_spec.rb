require 'rails_helper'

describe Blog do
  let(:blog)  { create(:blog, story: "Para1\n\n\nPara2\r\n\r\n", title: " Title\r\n  ") }

  it "normalisation" do
    expect(blog.title).to eq "Title"
    expect(blog.story).to eq "Para1\n\nPara2\n\n"
  end
end
