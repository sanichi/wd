require 'rails_helper'

describe Player, js: true do
  let!(:player) { create(:player) }

  let(:admin) { create(:user, roles: ["admin"]) }
  let(:data)  { build(:player) }

  before(:each) do
    login admin
    click_link t("player.players")
  end

  context "create" do
    it "success" do
      click_link t("player.new")
      fill_in t("player.first_name"), with: data.first_name
      fill_in t("player.last_name"), with: data.last_name
      data.roles.each { |role| select t("player.roles.#{role}"), from: t("player.roles.roles") }
      fill_in t("player.sca_id"), with: data.sca_id
      fill_in t("player.sca_rating"), with: data.sca_rating
      fill_in t("player.fide_id"), with: data.fide_id
      fill_in t("player.fide_rating"), with: data.fide_rating
      fill_in t("player.federation"), with: data.federation
      select (data.title || t("none")), from: t("player.title")
      fill_in t("player.email"), with: data.email
      fill_in t("player.phone"), with: data.phone
      data.contact? ? check(t("player.contact.contact")) : uncheck(t("player.contact.contact"))
      click_button t("save")

      expect(page).to have_title data.name

      expect(Player.count).to eq 2
      p = Player.find_by(first_name: data.first_name, last_name: data.last_name)
      expect(p.roles).to eq data.roles
      expect(p.sca_id).to eq data.sca_id
      expect(p.sca_rating).to eq data.sca_rating
      expect(p.fide_id).to eq data.fide_id
      expect(p.fide_rating).to eq data.fide_rating
      expect(p.federation).to eq data.federation
      expect(p.email).to eq data.email
      expect(p.phone).to eq data.phone
      expect(p.contact).to eq data.contact
    end

    it "no first name" do
      click_link t("player.new")
      fill_in t("player.last_name"), with: data.last_name
      data.roles.each { |role| select t("player.roles.#{role}"), from: t("player.roles.roles") }
      fill_in t("player.sca_id"), with: data.sca_id
      fill_in t("player.sca_rating"), with: data.sca_rating
      fill_in t("player.fide_id"), with: data.fide_id
      fill_in t("player.fide_rating"), with: data.fide_rating
      fill_in t("player.federation"), with: data.federation
      select (data.title || t("none")), from: t("player.title")
      fill_in t("player.email"), with: data.email
      fill_in t("player.phone"), with: data.phone
      data.contact? ? check(t("player.contact.contact")) : uncheck(t("player.contact.contact"))
      click_button t("save")

      expect(page).to have_title t("player.new")
      expect_error(page, "is invalid")

      expect(Player.count).to eq 1
    end
  end

  context "edit" do
    it "name" do
      click_link player.name
      click_link t("edit")

      expect(page).to have_title t("player.edit")
      fill_in t("player.first_name"), with: data.first_name
      fill_in t("player.last_name"), with: data.last_name
      click_button t("save")

      expect(page).to have_title data.name
      expect(Player.count).to eq 1

      p = Player.first
      expect(p.first_name).to eq data.first_name
      expect(p.last_name).to eq data.last_name
    end
  end

  context "delete" do
    it "success" do
      expect(Player.count).to eq 1

      click_link player.name
      click_link t("edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("player.players")

      expect(Player.count).to eq 0
    end
  end
end
