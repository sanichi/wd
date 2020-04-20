class PagesController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Non-RESTful-Controllers
  authorize_resource class: false

  def home
    @blogs = Blog.where(draft: false, pin: true).updated_des
    @blogs+= Blog.where(draft: false, pin: false).created_des.limit(5)
  end
end
