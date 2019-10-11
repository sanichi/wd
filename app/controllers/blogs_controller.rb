class BlogsController < ApplicationController
  before_action :find_blog, only: [:show, :edit, :update, :destroy]

  def index
    @blogs = Blog.search(params, blogs_path, remote: true, per_page: 10)
  end

  def new
    @blog = Blog.new
  end

  def create
    @blog = Blog.new(strong_params)
    if @blog.save
      redirect_to @blog, notice: t("created", thing: @blog.thing)
    else
      render :new
    end
  end

  def update
    if @blog.update(strong_params)
      redirect_to @blog, notice: t("updated", thing: @blog.thing)
    else
      render :edit
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path, alert: t("deleted", thing: @blog.thing)
  end

  private

  def find_blog
    @blog = Blog.find(params[:id])
  end

  def strong_params
    params.require(:blog).permit(:draft, :story, :summary, :title)
  end
end
