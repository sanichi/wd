module LmsFixtureHelper
  def lms_season_menu(selected)
    options_for_select(LmsFixture::SEASONS.map { |id, name| [name, id] }.reverse, selected)
  end

  def lms_event_menu(selected) = options_for_select(LmsFixture::EVENT_NAMES, selected)

  def lms_fixture_link(fixture)
    link_to fixture.fixture_id, "https://lms.playchess.org.uk/fixture/#{fixture.fixture_id}", target: "_blank", rel: "noopener", "data-turbo-frame" => "_top"
  end
end
