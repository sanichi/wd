class BooksController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Controller-Authorization-Example
  load_and_authorize_resource

  def index
    remember_last_path(:books)
    @books = Book.search(@books, params, books_path, per_page: 20)
  end

  def create
    if @book.save
      redirect_to @book, notice: success("created")
      journal "Book", "create", @book.id
    else
      failure @book
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @book.update(resource_params)
      redirect_to @book, notice: success("updated")
      journal "Book", "update", @book.id
    else
      failure @book
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, alert: success("deleted")
    journal "Book", "destroy", @book.id
  end

  private

  def resource_params
    params.require(:book).permit(:author, :borrowers, :category, :copies, :medium, :note, :title, :year)
  end

  def success(action)
    t("thing.#{action}", thing: t("book.thing", title: @book.title))
  end
end
