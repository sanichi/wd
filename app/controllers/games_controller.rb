class GamesController < ApplicationController
  load_and_authorize_resource

  def index
    @games = Game.search(@games, params, games_path, remote: true, per_page: 10)
  end

  def show
    @fen = PGN.parse(@game.pgn).first.positions.first.to_fen
  end

  def create
    assign_to_admin_if_no_user(@game)
    if @game.save
      redirect_to @game, notice: success("created")
    else
      failure @game
      render :new
    end
  end

  def update
    assign_to_admin_if_no_user(@game)
    if @game.update(resource_params)
      redirect_to @game, notice: success("updated")
    else
      failure @game
      render :edit
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, alert: success("deleted")
  end

  private

  def resource_params
    params.require(:game).permit(:difficulty, :pgn, :title)
  end

  def success(action)
    t("thing.#{action}", thing: t("game.thing", title: @game.title))
  end
end
