require 'rails_helper'

describe Blog do
  let!(:blog) { create(:blog, draft: false, user: blogger, pin: false) }

  let(:data)    { build(:blog, slug: "my_slug") }
  let(:blogger) { create(:user, roles: ["blogger"]) }

  before(:each) do
    login blogger
    visit blogs_path
  end

  context "create" do
    it "success" do
      click_link t("blog.new")
      fill_in t("blog.title"), with: data.title
      fill_in t("blog.summary"), with: data.summary
      fill_in t("blog.story"), with: data.story
      select data.tag ? t("blog.tags.#{data.tag}") : t("none"), from: t("blog.tag")
      data.draft? ? check(t("blog.draft")) : uncheck(t("blog.draft"))
      click_button t("save")

      expect(page).to have_title data.title

      expect(Blog.count).to eq 2
      b = Blog.order(:created_at).last
      expect(b.title).to eq data.title
      expect(b.summary).to eq data.summary
      expect(b.story).to eq data.story
      expect(b.tag).to eq data.tag
      expect(b.draft?).to eq data.draft
      expect(b.user).to eq blogger
      expect(b.slug).to be_nil
      expect(b.pin).to eq false
    end

    it "failure" do
      click_link t("blog.new")
      fill_in t("blog.title"), with: data.title
      fill_in t("blog.story"), with: data.story
      data.draft? ? check(t("blog.draft")) : uncheck(t("blog.draft"))
      click_button t("save")

      expect(page).to have_title t("blog.new")
      expect_error(page, "blank")

      expect(Blog.count).to eq 1
    end
  end

  context "edit" do
    it "title" do
      last_updated_at = blog.updated_at
      click_link blog.title
      click_link t("edit")

      expect(page).to have_title t("blog.edit")

      fill_in t("blog.title"), with: data.title
      click_button t("save")

      expect(page).to have_title data.title

      expect(Blog.count).to eq 1
      blog.reload
      expect(blog.title).to eq data.title
      expect(blog.updated_at).to eq last_updated_at
    end

    it "summary" do
      last_updated_at = blog.updated_at
      click_link blog.title
      click_link t("edit")

      expect(page).to have_title t("blog.edit")

      fill_in t("blog.summary"), with: data.summary
      click_button t("save")

      expect(page).to have_title blog.title

      expect(Blog.count).to eq 1
      blog.reload
      expect(blog.summary).to eq data.summary
      expect(blog.updated_at).to be > last_updated_at
    end

    it "slug and pin (admin)" do
      last_updated_at = blog.updated_at
      click_link t("session.sign_out")
      login create(:user, roles: ["admin"])
      visit blogs_path
      click_link blog.title
      click_link t("edit")

      expect(page).to have_title t("blog.edit")

      fill_in t("blog.slug"), with: data.slug
      check t("blog.pin")
      click_button t("save")

      expect(page).to have_title blog.title

      expect(Blog.count).to eq 1
      blog.reload
      expect(blog.slug).to eq data.slug
      expect(blog.pin).to eq true
      expect(blog.updated_at).to eq last_updated_at

      visit blog_path(data.slug)
      expect(page).to have_title blog.title
    end

    it "failure" do
      click_link blog.title
      click_link t("edit")

      fill_in t("blog.summary"), with: ""
      click_button t("save")

      expect(page).to have_title t("blog.edit")
      expect_error(page, "blank")
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
