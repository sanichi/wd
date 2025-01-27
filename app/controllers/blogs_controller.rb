class BlogsController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Controller-Authorization-Example
  # and https://github.com/CanCanCommunity/cancancan/wiki/Authorizing-controller-actions
  before_action :find_by_slug, only: [:edit, :update, :show, :destroy]
  load_and_authorize_resource

  def index
    remember_last_path(:blogs)
    @blogs = Blog.search(@blogs, params, blogs_path, per_page: 10)
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
    significant = %w/summary story/
    before = @blog.attributes.slice(*significant)
    last_updated_at = @blog.updated_at
    if @blog.update(resource_params)
      after = @blog.attributes.slice(*significant)
      # Revert updated_at (which determines order display order) if change is insignificant.
      if @blog.updated_at > last_updated_at && before == after
        @blog.update_column(:updated_at, last_updated_at)
      end
      redirect_to @blog, notice: success("updated")
      journal "Blog", "update", @blog.id
    else
      failure @blog
      render :edit
    end
  end

  def show
    if @blog.tag.present?
      @prev = Blog.by_id.where(tag: @blog.tag).where("id < #{@blog.id}").last
      @prev = nil if @prev && !can?(:read, @prev)
      @next = Blog.by_id.where(tag: @blog.tag).where("id > #{@blog.id}").first
      @next = nil if @next && !can?(:read, @next)
    end
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path, alert: success("deleted")
    journal "Blog", "destroy", @blog.id
  end

  private

  def find_by_slug
    @blog = Blog.find_by!(slug: params[:id]) if params[:id].match(Blog::VALID_SLUG)
  end

  def resource_params
    permitted = [:draft, :story, :summary, :tag, :title]
    permitted.concat [:pin, :slug] if current_user.admin?
    params.require(:blog).permit(*permitted)
  end

  def success(action)
    t("thing.#{action}", thing: t("blog.thing", title: @blog.title))
  end
end
