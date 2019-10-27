class PlayersController < ApplicationController
  load_and_authorize_resource

  def index
    @players = Player.search(@players, params)
  end

  def create
    if @player.save
      redirect_to @player, notice: success("created")
    else
      failure @player
      render :new
    end
  end

  def update
    if @player.update(resource_params)
      redirect_to @player, notice: success("updated")
    else
      failure @player
      render :edit
    end
  end

  def destroy
    @player.destroy
    redirect_to players_path, alert: success("deleted")
  end

  private

  def resource_params
    params.require(:player).permit(:contact, :email, :federation, :fide_id, :fide_rating, :first_name, :last_name, :phone, :sca_id, :sca_rating, :title, roles: [])
  end

  def success(action)
    t("thing.#{action}", thing: t("player.thing", name: @player.name))
  end
end
