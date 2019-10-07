class PagesController < ApplicationController
  def home
    @blogs = Blog.created_des.where(draft: false).limit(5)
  end
end
