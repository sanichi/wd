require 'rails_helper'

describe Game do
  let!(:game) { create(:game, user: admin, pgn: file("vaganian_pogonina.pgn")) }

  let(:data)  { build(:game, pgn: file("lee_orr.pgn")) }
  let(:admin) { create(:user, roles: ["admin"]) }

  before(:each) do
    login admin
    visit games_path
  end

  context "create" do
    context "success" do
      it "with title" do
        click_link t("game.new")
        fill_in t("game.title"), with: data.title
        fill_in t("game.pgn"), with: data.pgn
        click_button t("save")

        expect(page).to have_title data.title

        expect(Game.count).to eq 2
        g = Game.order(:created_at).last
        expect(g.pgn).to eq data.pgn
        expect(g.title).to eq data.title
      end

      it "without title" do
        click_link t("game.new")
        fill_in t("game.pgn"), with: data.pgn
        click_button t("save")

        correct_title = "Lee, C. - Orr, M., Largs Open, 1998, 0-1"
        expect(page).to have_title correct_title

        expect(Game.count).to eq 2
        g = Game.order(:created_at).last
        expect(g.pgn).to eq data.pgn
        expect(g.title).to eq correct_title
      end
    end

    context "failure" do
      it "no PGN" do
        click_link t("game.new")
        fill_in t("game.title"), with: data.title
        click_button t("save")

        expect(page).to have_title t("game.new")
        expect_error(page, "blank")

        expect(Game.count).to eq 1
      end
    end
  end

  context "edit" do
    it "title" do
      click_link game.title
      click_link t("edit")
      fill_in t("game.title"), with: data.title
      click_button t("save")

      expect(page).to have_title data.title

      expect(Game.count).to eq 1
      game.reload
      expect(game.title).to eq data.title
    end

    it "pgn" do
      click_link game.title
      click_link t("edit")
      fill_in t("game.pgn"), with: data.pgn
      click_button t("save")

      expect(page).to have_title game.title

      expect(Game.count).to eq 1
      game.reload
      expect(game.pgn).to eq data.pgn
    end
  end

  context "delete" do
    it "success" do
      expect(Game.count).to eq 1

      click_link game.title
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("game.games")

      expect(Game.count).to eq 0
    end
  end
end
