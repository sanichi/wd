class PagesController < ApplicationController
  authorize_resource

  def home
    @blogs = Blog.where(draft: false, pin: true).updated_des
    @blogs+= Blog.where(draft: false, pin: false).created_des.limit(5)
  end
end
