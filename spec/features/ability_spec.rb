require 'rails_helper'

describe Ability do
  let(:admin)   { create(:user, role: "admin") }
  let(:blogger) { create(:user, role: "blogger") }
  let(:member)  { create(:user, role: "member") }
  let!(:blog)   { create(:blog, draft: false) }

  context "admin" do
    before(:each) do
      login(admin)
    end

    it "blogs" do
      expect(page).to have_selector "a", text: t("blog.blogs")
      click_link t("blog.blogs")
      expect(page).to have_selector "a", text: blog.title
      click_link blog.title
      expect(page).to have_selector "a", text: t("edit")
      click_link t("edit")
      expect(page).to have_selector "a", text: t("cancel")
      expect(page).to have_selector "a", text: t("delete")
      click_link t("cancel")
    end

    it "users" do
      expect(page).to have_selector "a", text: t("user.users")
      click_link t("user.users")
      expect(page).to have_selector "a", text: admin.handle
      click_link admin.handle
      expect(page).to have_selector "a", text: t("edit")
      click_link t("edit")
      expect(page).to have_selector "a", text: t("cancel")
      expect(page).to have_selector "a", text: t("delete")
      click_link t("cancel")
    end
  end

  context "blogger" do
    before(:each) do
      login(blogger)
    end

    it "blogs" do
      expect(page).to have_selector "a", text: t("blog.blogs")
      click_link t("blog.blogs")
      expect(page).to have_selector "a", text: blog.title
      click_link blog.title
      expect(page).to have_selector "a", text: t("edit")
      click_link t("edit")
      expect(page).to have_selector "a", text: t("cancel")
      expect(page).to have_selector "a", text: t("delete")
      click_link t("cancel")
    end

    it "users" do
      expect(page).to have_selector "a", text: t("user.users")
      click_link t("user.users")
      expect(page).to_not have_selector "a", text: blogger.handle
      visit user_path(blogger)
      expect_unauthorized(page)
      visit edit_user_path(blogger)
      expect_unauthorized(page)
    end
  end

  context "member" do
    before(:each) do
      login(member)
    end

    it "blogs" do
      expect(page).to have_selector "a", text: t("blog.blogs")
      click_link t("blog.blogs")
      expect(page).to have_selector "a", text: blog.title
      click_link blog.title
      expect(page).to_not have_selector "a", text: t("edit")
      visit edit_blog_path(blog)
      expect_unauthorized(page)
    end

    it "users" do
      expect(page).to have_selector "a", text: t("user.users")
      click_link t("user.users")
      expect(page).to_not have_selector "a", text: blogger.handle
      visit user_path(blogger)
      expect_unauthorized(page)
      visit edit_user_path(blogger)
      expect_unauthorized(page)
    end
  end
end
