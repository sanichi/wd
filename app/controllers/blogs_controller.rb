class BlogsController < ApplicationController
  authorize_resource
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
      @blog.update_column(:user_id, current_user.id)
      redirect_to @blog, notice: t("thing.created", thing: @blog.thing)
    else
      render :new
    end
  end

  def update
    if @blog.update(strong_params)
      @blog.update_column(:user_id, current_user.id) unless @blog.user.present?
      redirect_to @blog, notice: t("thing.updated", thing: @blog.thing)
    else
      render :edit
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path, alert: t("thing.deleted", thing: @blog.thing)
  end

  private

  def find_blog
    @blog = Blog.find(params[:id])
  end

  def strong_params
    params.require(:blog).permit(:draft, :story, :summary, :title)
  end
end
