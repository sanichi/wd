class PagesController < ApplicationController
  def home
    @blogs = Blog.where(draft: false, pin: true).updated_des
    @blogs+= Blog.where(draft: false, pin: false).created_des.limit(5)
  end

  def contacts
    if current_user.guest?
      @players = Player.where(contact: true).by_rank
    else
      @players = Player.by_name
    end
  end
end
