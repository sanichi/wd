class PagesController < ApplicationController
  def home
    @blogs = Blog.where(draft: false, pin: true).updated_descending
    @blogs+= Blog.where(draft: false, pin: false).created_descending.limit(5)
  end

  def contacts
    if current_user.guest?
      @players = Player.where(contact: true).order(:rank)
    else
      @players = Player.order(:first_name, :last_name)
    end
  end
end
