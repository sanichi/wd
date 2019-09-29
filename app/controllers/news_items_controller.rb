class NewsItemsController < ApplicationController

  def index
    flash[:alert] = "Hello"
  end
end
