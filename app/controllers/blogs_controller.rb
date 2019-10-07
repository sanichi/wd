class BlogsController < ApplicationController
  before_action :find_blog, only: [:show, :edit, :update, :destroy]
  before_action :protect_production, only: [:new, :create, :edit, :update, :destroy]

  def index
    @blogs = Blog.search(params, blogs_path, remote: true, per_page: 10)
  end

  def new
    @blog = Blog.new(draft: true)
  end

  def create
    @blog = Blog.new(strong_params)
    if @blog.save
      redirect_to @blog
    else
      render "new"
    end
  end

  def update
    if @blog.update(strong_params)
      redirect_to @blog
    else
      render action: "edit"
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path
  end

  private

  def find_blog
    @blog = Blog.find(params[:id])
  end

  def protect_production
    if Rails.env.production?
      redirect_to blogs_path
    end
  end

  def strong_params
    params.require(:blog).permit(:draft, :story, :summary, :title)
  end
end
