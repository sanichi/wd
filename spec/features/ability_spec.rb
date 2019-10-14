require 'rails_helper'

describe Ability do
  def expect_save_cancel_delete(page)
    expect(page).to have_button t("save")
    expect(page).to have_css "a", text: t("cancel")
    expect(page).to have_css "a", text: t("delete")
  end

  def expect_no_edit(page)
    expect(page).to_not have_css "a", text: t("edit")
  end

  def expect_no_go(path, page)
    visit path
    expect(page).to have_css "div.alert.alert-dismissable", text: t("unauthorized.default")
  end

  let!(:blog1) { create(:blog, draft: false, user: blogger1) }
  let!(:blog2) { create(:blog, draft: false, user: blogger2) }

  let(:admin)    { create(:user, role: "admin") }
  let(:blogger1) { create(:user, role: "blogger") }
  let(:blogger2) { create(:user, role: "blogger") }
  let(:member)   { create(:user, role: "member") }

  context "admin" do
    before(:each) do
      login admin
    end

    it "blogs" do
      [blog1, blog2].each do |blog|
        click_link t("blog.blogs")
        click_link blog.title
        click_link t("edit")
        expect_save_cancel_delete(page)
      end
    end

    it "users" do
      [admin, blogger1, blogger2].each do |user|
        click_link t("user.users")
        click_link user.handle
        click_link t("edit")
        expect_save_cancel_delete(page)
      end
    end
  end

  context "blogger" do
    before(:each) do
      login blogger1
    end

    it "blogs" do
      click_link t("blog.blogs")
      click_link blog1.title
      click_link t("edit")
      expect_save_cancel_delete(page)

      click_link t("blog.blogs")
      click_link blog2.title
      expect_no_edit page
      expect_no_go edit_blog_path(blog2), page
    end

    it "users" do
      [blogger1, blogger2].each do |blogger|
        click_link t("user.users")
        expect(page).to have_css "td", text: blogger.handle
        expect(page).to_not have_css "a", text: blogger.handle
        expect_no_go user_path(blogger), page
        expect_no_go edit_user_path(blogger), page
      end
    end
  end

  context "member" do
    before(:each) do
      login member
    end

    it "blogs" do
      [blog1, blog2].each do |blog|
        click_link t("blog.blogs")
        click_link blog.title
        expect_no_edit page
        expect_no_go edit_blog_path(blog), page
      end
    end

    it "users" do
      [member, blogger1, blogger2].each do |user|
        click_link t("user.users")
        expect(page).to have_css "td", text: user.handle
        expect_no_edit(page)
        expect_no_go user_path(user), page
        expect_no_go edit_user_path(user), page
      end
    end
  end
end
