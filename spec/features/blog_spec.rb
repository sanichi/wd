require 'rails_helper'

describe Blog do
  let(:data)  { build(:blog) }
  let!(:blog) { create(:blog, draft: false) }

  before(:each) do
    visit blogs_path
  end

  context "create" do
    it "success" do
      click_link t("blog.new")
      fill_in t("blog.title"), with: data.title
      fill_in t("blog.summary"), with: data.summary
      fill_in t("blog.story"), with: data.story
      data.draft ? check(t("blog.draft")) : uncheck(t("blog.draft"))
      click_button t("save")

      expect(page).to have_title data.title

      expect(Blog.count).to eq 2
      b = Blog.last
      expect(b.title).to eq data.title
      expect(b.summary).to eq data.summary
      expect(b.story).to eq data.story
      expect(b.draft).to eq data.draft
    end

    it "failure" do
      click_link t("blog.new")
      fill_in t("blog.title"), with: data.title
      fill_in t("blog.story"), with: data.story
      data.draft ? check(t("blog.draft")) : uncheck(t("blog.draft"))
      click_button t("save")

      expect(page).to have_title t("blog.new")
      expect(page).to have_css(error, text: "blank")

      expect(Blog.count).to eq 1
    end
  end

  context "edit" do
    it "success" do
      click_link blog.title
      click_link t("edit")

      expect(page).to have_title t("blog.edit")

      fill_in t("blog.title"), with: data.title
      click_button t("save")

      expect(page).to have_title data.title

      expect(Blog.count).to eq 1
      b = Blog.last
      expect(b.title).to eq data.title
    end

    it "failure" do
      click_link blog.title
      click_link t("edit")

      fill_in t("blog.summary"), with: ""
      click_button t("save")

      expect(page).to have_title t("blog.edit")
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Blog.count).to eq 1

      click_link blog.title
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("blog.blogs")

      expect(Blog.count).to eq 0
    end
  end
end
