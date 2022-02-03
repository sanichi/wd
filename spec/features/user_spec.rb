require 'rails_helper'

describe User do
  let!(:user) { create(:user) }
  let!(:otpu) { create(:user, otp_required: true ) }

  let(:admin) { create(:user, roles: ["admin"]) }
  let(:data)  { build(:user) }

  context "admin" do
    before(:each) do
      login admin
      click_link t("user.users")
    end

    context "create" do
      it "user" do
        click_link t("user.new")

        fill_in t("user.handle"), with: data.handle
        fill_in t("user.password"), with: data.password
        data.roles.each { |role| select t("user.roles.#{role}"), from: t("user.roles.roles") }
        fill_in t("user.first_name"), with: data.first_name
        fill_in t("user.last_name"), with: data.last_name
        uncheck t("otp.required")
        click_button t("save")

        expect(page).to have_title t("user.thing", handle: data.handle)
        expect(User.count).to eq 4
        u = User.find_by(handle: data.handle)
        expect(u.password).to be_nil
        expect(u.password_digest).to be_present
        expect(u.roles).to eq data.roles
        expect(u.first_name).to eq data.first_name
        expect(u.last_name).to eq data.last_name
        expect(u.otp_required).to eq false
        expect(u.otp_secret).to be_nil
        expect(u.last_otp_at).to be_nil

        click_link t("session.sign_out")
        click_link t("session.sign_in")

        fill_in t("user.handle"), with: data.handle
        fill_in t("user.password"), with: data.password
        click_button t("session.sign_in")

        expect_notice(page, t("session.success", name: u.first_name))
      end

      it "otp user" do
        click_link t("user.new")

        fill_in t("user.handle"), with: data.handle
        fill_in t("user.password"), with: data.password
        data.roles.each { |role| select t("user.roles.#{role}"), from: t("user.roles.roles") }
        fill_in t("user.first_name"), with: data.first_name
        fill_in t("user.last_name"), with: data.last_name
        check t("otp.required")
        click_button t("save")

        expect(page).to have_title t("user.thing", handle: data.handle)

        expect(User.count).to eq 4
        u = User.find_by(handle: data.handle)
        expect(u.password).to be_nil
        expect(u.password_digest).to be_present
        expect(u.roles).to eq data.roles
        expect(u.first_name).to eq data.first_name
        expect(u.last_name).to eq data.last_name
        expect(u.otp_required).to eq true
        expect(u.otp_secret).to be_nil
        expect(u.last_otp_at).to be_nil

        click_link t("session.sign_out")
        click_link t("session.sign_in")

        fill_in t("user.handle"), with: data.handle
        fill_in t("user.password"), with: data.password
        click_button t("session.sign_in")

        expect(page).to have_title t("otp.new")

        fill_in t("otp.otp"), with: otp_attempt
        click_button t("otp.submit")

        expect_notice(page, t("session.success", name: u.first_name))
      end

      it "no password" do
        click_link t("user.new")

        fill_in t("user.handle"), with: data.handle
        data.roles.each { |role| select t("user.roles.#{role}"), from: t("user.roles.roles") }
        fill_in t("user.first_name"), with: data.first_name
        fill_in t("user.last_name"), with: data.last_name
        uncheck t("otp.required")
        click_button t("save")

        expect(page).to have_title t("user.new")
        expect_error(page, "blank")
        expect(User.count).to eq 3
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

        expect(page).to have_title t("user.thing", handle: user.handle)
        expect(User.count).to eq 3

        u = User.find_by(handle: user.handle)
        expect(u.first_name).to eq data.first_name
        expect(u.last_name).to eq data.last_name
      end
    end

    context "delete" do
      it "success" do
        expect(User.count).to eq 3

        click_link user.handle
        click_link t("edit")
        click_link t("delete")

        expect(page).to have_title t("user.users")

        expect(User.count).to eq 2
      end
    end
  end

  context "login" do
    it "user" do
      visit home_path

      click_link t("session.sign_in")
      fill_in t("user.handle"), with: user.handle
      fill_in t("user.password"), with: user.password
      click_button t("session.sign_in")

      expect_notice(page, t("session.success", name: user.first_name))
    end

    it "otp user" do
      visit home_path

      click_link t("session.sign_in")
      fill_in t("user.handle"), with: otpu.handle
      fill_in t("user.password"), with: otpu.password
      click_button t("session.sign_in")

      expect(page).to have_title t("otp.challenge")

      fill_in t("otp.otp"), with: otp_attempt
      click_button t("otp.submit")

      expect_notice(page, t("session.success", name: otpu.first_name))
    end
  end
end
