class JournalsController < ApplicationController
  load_and_authorize_resource

  def index
    @journals = Journal.search(@journals, params, journals_path, remote: true, per_page: 20)
  end
end
