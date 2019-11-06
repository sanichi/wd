require 'rails_helper'

describe Ability do

  it "guest" do
    visit home_path

    click_link t("blog.blogs")
    expect(page).to_not have_css "a", text: t("blog.new")

    click_link t("book.books")
    expect(page).to_not have_css "a", text: t("book.new")

    click_link t("game.games")
    expect(page).to_not have_css "a", text: t("game.new")

    click_link t("player.players")
    expect(page).to_not have_css "a", text: t("players.new")

    expect(page).to_not have_css "a", text: t("user.users")
  end

  it "member" do
    login create(:user, roles: ["member"])

    click_link t("blog.blogs")
    expect(page).to_not have_css "a", text: t("blog.new")

    click_link t("book.books")
    expect(page).to_not have_css "a", text: t("book.new")

    click_link t("game.games")
    expect(page).to_not have_css "a", text: t("game.new")

    click_link t("player.players")
    expect(page).to_not have_css "a", text: t("players.new")

    click_link t("user.users")
    expect(page).to_not have_css "a", text: t("user.new")
  end

  it "librarian" do
    login create(:user, roles: ["librarian"])

    click_link t("blog.blogs")
    expect(page).to_not have_css "a", text: t("blog.new")

    click_link t("book.books")
    click_link t("book.new")

    click_link t("game.games")
    expect(page).to_not have_css "a", text: t("game.new")

    click_link t("player.players")
    expect(page).to_not have_css "a", text: t("players.new")

    click_link t("user.users")
    expect(page).to_not have_css "a", text: t("user.new")
  end

  it "blogger" do
    login create(:user, roles: ["blogger"])

    click_link t("blog.blogs")
    click_link t("blog.new")

    click_link t("book.books")
    expect(page).to_not have_css "a", text: t("book.new")

    click_link t("game.games")
    click_link t("game.new")

    click_link t("player.players")
    expect(page).to_not have_css "a", text: t("players.new")

    click_link t("user.users")
    expect(page).to_not have_css "a", text: t("user.new")
  end

  it "admin" do
    login create(:user, roles: ["admin"])

    click_link t("blog.blogs")
    click_link t("blog.new")

    click_link t("book.books")
    click_link t("book.new")

    click_link t("game.games")
    click_link t("game.new")

    click_link t("player.players")
    click_link t("player.new")

    click_link t("user.users")
    click_link t("user.new")
  end
end
