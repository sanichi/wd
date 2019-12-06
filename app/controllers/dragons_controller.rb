class DragonsController < ApplicationController
  # see https://github.com/CanCanCommunity/cancancan/wiki/Controller-Authorization-Example
  load_and_authorize_resource

  def index
    @dragons = Dragon.search(@dragons, params, dragons_path, remote: true, per_page: 20)
  end
end
