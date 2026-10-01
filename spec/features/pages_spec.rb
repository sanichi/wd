require 'rails_helper'

describe PagesController, js: true do
  before(:each) do
    visit home_path
  end

  context "home" do
    it "show" do
      expect(page).to have_title t("home.title")
    end
  end

  context "home blog footer" do
    let(:blogger) { create(:user, roles: ["blogger"]) }
    let(:other)   { create(:user, roles: ["blogger"]) }
    let!(:blog)   { create(:blog, draft: false, pin: false, user: blogger) }

    it "guest sees handle" do
      visit home_path
      expect(page).to have_content blogger.handle
      expect(page).to_not have_link t("edit")
    end

    it "owner sees edit link" do
      login blogger
      visit home_path
      expect(page).to_not have_content blogger.handle
      click_link t("edit")
      expect(page).to have_title t("blog.edit")
    end

    it "other blogger sees handle" do
      login other
      visit home_path
      within("article", text: blog.title) do
        expect(page).to have_content blogger.handle
        expect(page).to_not have_link t("edit")
      end
    end
  end

  context "help" do
    it "show" do
      click_link t("other")
      click_link t("help.help")
      expect(page).to have_title t("help.help")
    end
  end

  context "contacts" do
    it "show" do
      click_link t("player.contact.contacts")
      expect(page).to have_title t("player.contact.contacts")
    end
  end

  context "dragons" do
    it "show" do
      click_link t("history")
      click_link t("dragon.dragons")
      expect(page).to have_title t("dragon.dragons")
    end
  end
end
