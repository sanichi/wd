require 'rails_helper'

describe User do
  let(:data)  { build(:user) }
  let!(:user) { create(:user) }

  before(:each) do
    visit users_path
  end

  context "create" do
    it "success" do
      click_link t("user.new")
      fill_in t("user.handle"), with: data.handle
      fill_in t("user.password"), with: data.password
      select t("user.roles.#{data.role}"), from: t("user.role")
      fill_in t("user.first_name"), with: data.first_name
      fill_in t("user.last_name"), with: data.last_name
      click_button t("save")

      expect(page).to have_title "#{t('user.user')} #{data.handle}"

      expect(User.count).to eq 2
      u = User.last
      expect(u.handle).to eq data.handle
      expect(u.password).to be_nil
      expect(u.password_digest).to be_present
      expect(u.role).to eq data.role
      expect(u.first_name).to eq data.first_name
      expect(u.last_name).to eq data.last_name
    end

    it "no password" do
      click_link t("user.new")
      fill_in t("user.handle"), with: data.handle
      select t("user.roles.#{data.role}"), from: t("user.role")
      fill_in t("user.first_name"), with: data.first_name
      fill_in t("user.last_name"), with: data.last_name
      click_button t("save")

      expect(page).to have_title t("user.new")
      expect(page).to have_css(error, text: "blank")

      expect(User.count).to eq 1
    end
  end

  context "edit" do
    it "name" do
      click_link user.handle
      click_link t("edit")

      expect(page).to have_title t("user.edit")
      fill_in t("user.first_name"), with: data.first_name
      fill_in t("user.last_name"), with: data.last_name
      click_button t("save")

      expect(page).to have_title "#{t('user.user')} #{user.handle}"
      expect(User.count).to eq 1

      u = User.last
      expect(u.first_name).to eq data.first_name
      expect(u.last_name).to eq data.last_name
    end
  end

  context "delete" do
    it "success" do
      expect(User.count).to eq 1

      click_link user.handle
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("user.users")

      expect(User.count).to eq 0
    end
  end
end