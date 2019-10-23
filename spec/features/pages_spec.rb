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

  context "contacts" do
    it "show" do
      click_link t("contact.contacts")
      expect(page).to have_title t("contact.contacts")
    end
  end
end
