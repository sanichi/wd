class BlogsController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Controller-Authorization-Example
  load_and_authorize_resource
  skip_load_and_authorize_resource only: :show

  def index
    @blogs = Blog.search(@blogs, params, blogs_path, remote: true, per_page: 10)
  end

  def show
    if params[:id].match(Blog::VALID_TAG)
      @blog = Blog.find_by!(tag: params[:id])
    else
      @blog = Blog.find(params[:id])
    end
    authorize! :show, @blog
  end

  def create
    if @blog.save
      assign_to_admin_if_no_user
      redirect_to @blog, notice: t("thing.created", thing: @blog.thing)
    else
      render :new
    end
  end

  def update
    if @blog.update(resource_params)
      assign_to_admin_if_no_user
      redirect_to @blog, notice: t("thing.updated", thing: @blog.thing)
    else
      render :edit
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path, alert: t("thing.deleted", thing: @blog.thing)
  end

  def pin
    @blog.update_column(:pin, !@blog.pin)
    @blog.touch
  end

  private

  def resource_params
    params.require(:blog).permit(:draft, :story, :summary, :tag, :title)
  end

  # load_and_authorize_resource will not set the user_id for admins since they can manage all
  def assign_to_admin_if_no_user
    if @blog.user.blank? && current_user.admin?
      @blog.update_column(:user_id, current_user.id)
    end
  end
end
