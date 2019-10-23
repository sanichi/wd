class PagesController < ApplicationController
  def home
    @blogs = Blog.where(draft: false, pin: true).updated_descending
    @blogs+= Blog.where(draft: false, pin: false).created_descending.limit(5)
  end

  def contacts
    @players = Player.where(contact: true).order(:rank)
  end
end
