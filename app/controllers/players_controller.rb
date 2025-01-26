class PlayersController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Controller-Authorization-Example
  # and https://github.com/CanCanCommunity/cancancan/wiki/Authorizing-controller-actions
  before_action :find_by_slug, only: [:edit, :update, :show, :destroy]
  load_and_authorize_resource

  def index
    remember_last_path(:players)
    @players = Player.search(@players, params)
  end

  def contacts
    if current_user.guest?
      @players = @players.where(contact: true).by_rank
      @emails = ""
      @count = 0
    else
      @players = Player.search(@players, params, contacts: true)
      emails = @players.map(&:long_email).compact
      @emails = emails.join(", ")
      @count = emails.size
    end
  end

  def create
    if @player.save
      redirect_to @player, notice: success("created")
      journal "Player", "create", @player.id
    else
      failure @player
      render :new
    end
  end

  def update
    if @player.update(resource_params)
      redirect_to @player, notice: success("updated")
      journal "Player", "update", @player.id
    else
      failure @player
      render :edit
    end
  end

  def destroy
    @player.destroy
    redirect_to players_path, alert: success("deleted")
    journal "Player", "destroy", @player.id
  end

  private

  def find_by_slug
    @player = Player.find_by!(slug: params[:id])
  end

  def resource_params
    params.require(:player).permit(:contact, :email, :federation, :fide_id, :fide_rating, :first_name, :last_name, :phone, :sca_id, :sca_rating, :title, roles: [])
  end

  def success(action)
    t("thing.#{action}", thing: t("player.thing", name: @player.name))
  end
end
