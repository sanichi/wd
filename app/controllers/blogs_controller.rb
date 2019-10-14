class BlogsController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Controller-Authorization-Example
  load_and_authorize_resource

  def index
    @blogs = Blog.search(@blogs, params, blogs_path, remote: true, per_page: 10)
  end

  def create
    if @blog.save
      redirect_to @blog, notice: t("thing.created", thing: @blog.thing)
    else
      render :new
    end
  end

  def update
    if @blog.update(resource_params)
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

  def resource_params
    params.require(:blog).permit(:draft, :story, :summary, :title)
  end
end
