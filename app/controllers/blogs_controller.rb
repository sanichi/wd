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
    assign_to_admin_if_no_user(@blog)
    if @blog.save
      redirect_to @blog, notice: success("created")
      journal "Blog", "create", @blog.id
    else
      failure @blog
      render :new
    end
  end

  def update
    assign_to_admin_if_no_user(@blog)
    if @blog.update(resource_params)
      redirect_to @blog, notice: success("updated")
      journal "Blog", "update", @blog.id
    else
      failure @blog
      render :edit
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path, alert: success("deleted")
    journal "Blog", "destroy", @blog.id
  end

  private

  def resource_params
    permitted = [:draft, :story, :summary, :title]
    permitted.concat [:pin, :tag] if current_user.admin?
    params.require(:blog).permit(*permitted)
  end

  def success(action)
    t("thing.#{action}", thing: t("blog.thing", title: @blog.title))
  end
end
