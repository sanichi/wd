class LmsFixturesController < ApplicationController
  load_and_authorize_resource

  def index
    @season = LmsFixture.season_from(params)
    @event  = LmsFixture.event_from(params)
    @lms_fixtures = LmsFixture.search(@lms_fixtures, params, lms_fixtures_path, per_page: 30)
  end
end
