require 'rails_helper'

describe Ability do

  it "guest" do
    visit home_path

    click_link t("blog.blogs")
    expect(page).to_not have_css "a", text: t("blog.new")

    click_link t("game.games")
    expect(page).to_not have_css "a", text: t("game.new")

    expect(page).to_not have_css "a", text: t("player.players")
    visit players_path
    expect_error(page, "not authorized")

    expect(page).to_not have_css "a", text: t("book.books")
    visit books_path
    expect_error(page, "not authorized")

    expect(page).to_not have_css "a", text: t("user.users")
    visit users_path
    expect_error(page, "not authorized")
  end

  it "member" do
    login create(:user, roles: ["member"])

    click_link t("blog.blogs")
    expect(page).to_not have_css "a", text: t("blog.new")

    click_link t("game.games")
    expect(page).to_not have_css "a", text: t("game.new")

    click_link t("user.users")
    expect(page).to_not have_css "a", text: t("user.new")

    expect(page).to_not have_css "a", text: t("player.players")
    visit players_path
    expect_error(page, "not authorized")

    expect(page).to_not have_css "a", text: t("book.books")
    visit books_path
    expect_error(page, "not authorized")
  end

  it "librarian" do
    login create(:user, roles: ["librarian"])

    click_link t("blog.blogs")
    expect(page).to_not have_css "a", text: t("blog.new")

    click_link t("book.books")
    click_link t("book.new")

    click_link t("game.games")
    expect(page).to_not have_css "a", text: t("game.new")

    click_link t("user.users")
    expect(page).to_not have_css "a", text: t("user.new")

    expect(page).to_not have_css "a", text: t("player.players")
    visit players_path
    expect_error(page, "not authorized")
  end

  it "blogger" do
    login create(:user, roles: ["blogger"])

    click_link t("blog.blogs")
    click_link t("blog.new")

    click_link t("game.games")
    click_link t("game.new")

    click_link t("user.users")
    expect(page).to_not have_css "a", text: t("user.new")

    expect(page).to_not have_css "a", text: t("player.players")
    visit players_path
    expect_error(page, "not authorized")

    expect(page).to_not have_css "a", text: t("book.books")
    visit books_path
    expect_error(page, "not authorized")
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
