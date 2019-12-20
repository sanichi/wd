require 'rails_helper'

describe PagesController do
  before(:each) do
    visit home_path
  end

  context "home" do
    it "show" do
      expect(page).to have_title t("home.title")
    end
  end

  context "help" do
    it "show" do
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
      click_link t("dragon.dragons")
      expect(page).to have_title t("dragon.dragons")
    end
  end

  context "registration" do
    it "show" do
      visit registration_players_path # currently we don't advertise this page, it's meant for SCA admins
      expect(page).to have_title t("player.registration.registration")
    end
  end
end
