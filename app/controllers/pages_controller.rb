class PagesController < ApplicationController
  def home
    @blogs = Blog.where(draft: false, pin: true).updated_des + Blog.where(draft: false).created_des.limit(5)
  end
end
