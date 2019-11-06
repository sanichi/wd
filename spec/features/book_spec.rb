require 'rails_helper'

describe Book do
  let!(:book) { create(:book) }

  let(:data)  { build(:book) }
  let(:librarian)  { create(:user, roles: ["librarian"]) }

  before(:each) do
    login librarian
    visit books_path
  end

  context "create" do
    it "success" do
      click_link t("book.new")
      fill_in t("book.title"), with: data.title
      fill_in t("book.author"), with: data.author
      fill_in t("book.year"), with: data.year
      fill_in t("book.copies"), with: data.copies
      fill_in t("book.borrowers"), with: data.borrowers
      select I18n.t("book.categories.#{data.category}"), from: t("book.category")
      select I18n.t("book.media.#{data.medium}"), from: t("book.medium")
      fill_in t("book.note"), with: data.note
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Book.count).to eq 2
      b = Book.order(:created_at).last

      expect(b.title).to eq data.title
      expect(b.author).to eq data.author
      expect(b.year).to eq data.year
      expect(b.borrowers).to eq data.borrowers
      expect(b.category).to eq data.category
      expect(b.medium).to eq data.medium
      expect(b.note).to eq data.note
    end

    it "failure" do
      click_link t("book.new")
      fill_in t("book.author"), with: data.author
      fill_in t("book.year"), with: data.year
      fill_in t("book.copies"), with: data.copies
      fill_in t("book.borrowers"), with: data.borrowers
      select I18n.t("book.categories.#{data.category}"), from: t("book.category")
      select I18n.t("book.media.#{data.medium}"), from: t("book.medium")
      fill_in t("book.note"), with: data.note
      click_button t(:save)

      expect(page).to have_title t("book.new")
      expect_error(page, "blank")

      expect(Book.count).to eq 1
    end
  end

  context "edit" do
    it "success" do
      click_link book.title
      click_link t("edit")

      expect(page).to have_title t("book.edit")
      fill_in t("book.title"), with: data.title
      click_button t("save")

      expect(page).to have_title data.title

      expect(Book.count).to eq 1
      book.reload

      expect(book.title).to eq data.title
    end

    it "failure" do
      click_link book.title
      click_link t(:edit)

      fill_in t("book.author"), with: ""
      click_button t(:save)

      expect(page).to have_title t("book.edit")
      expect_error(page, "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Book.count).to eq 1

      click_link book.title
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t("book.books")

      expect(Book.count).to eq 0
    end
  end
end
