require 'rails_helper'

describe SessionsController do
  let(:data) { build(:user) }
  let(:user) { create(:user) }

  before(:each) do
    visit home_path
  end

  context "sign in" do
    it "success" do
      expect(page).to have_css "a", text: t("session.sign_in")
      expect(page).to_not have_css "a", text: t("session.sign_out")

      click_link t("session.sign_in")
      expect(page).to have_title t("session.sign_in")
      expect(page).to_not have_css "a", text: t("session.sign_in")
      expect(page).to_not have_css "a", text: t("session.sign_out")

      fill_in t("user.handle"), with: user.handle
      fill_in t("user.password"), with: user.password
      click_button t("session.sign_in")
      expect(page).to have_title t("home.title")
      expect(page).to_not have_css "a", text: t("session.sign_in")
      expect(page).to have_css "a", text: t("session.sign_out")

      click_link t("session.sign_out")
      expect(page).to have_title t("home.title")
      expect(page).to have_css "a", text: t("session.sign_in")
      expect(page).to_not have_css "a", text: t("session.sign_out")
    end

    it "failure" do
      click_link t("session.sign_in")

      fill_in t("user.handle"), with: user.handle
      fill_in t("user.password"), with: data.password
      click_button t("session.sign_in")
      expect(page).to have_title t("session.sign_in")
      expect(page).to_not have_css "a", text: t("session.sign_in")
      expect(page).to_not have_css "a", text: t("session.sign_out")
    end

    it "cancel" do
      click_link t("session.sign_in")

      click_link t("cancel")
      expect(page).to have_title t("home.title")
      expect(page).to have_css "a", text: t("session.sign_in")
      expect(page).to_not have_css "a", text: t("session.sign_out")
    end
  end
end
