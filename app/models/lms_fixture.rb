class LmsFixture < ApplicationRecord
  include Pageable

  class ImportError < StandardError; end

  MAX_EVENT_NAME = 12

  # LMS season IDs (the Edinburgh league), updated each year.
  SEASONS = {
    11 => "2025/26",
    12 => "2026/27",
  }.freeze

  # Only fixtures involving a team whose name starts with this are stored.
  CLUB = "Wandering Dragons"

  # Events whose fixtures can appear in blogs.
  EVENT_NAMES = ["Premier", "Division 1", "Division 2", "Division 3"].freeze

  validates :season_id, :event_id, :fixture_id, presence: true, numericality: { only_integer: true }
  validates :fixture_id, uniqueness: true
  validates :event_name, presence: true, length: { maximum: MAX_EVENT_NAME }

  scope :by_event, -> { order(:event_id, :fixture_id) }

  # The season to show when none is asked for: the latest one with data.
  def self.default_season = maximum(:season_id) || SEASONS.keys.max

  def self.season_from(params)
    season = params[:season].to_i
    SEASONS.key?(season) ? season : default_season
  end

  def self.event_from(params) = EVENT_NAMES.include?(params[:event]) ? params[:event] : EVENT_NAMES.first

  def self.search(matches, params, path, opt={})
    matches = matches.where(season_id: season_from(params), event_name: event_from(params)).by_event
    paginate(matches, params, path, opt)
  end

  # Replaces any stored fixtures for the season with the club's fixtures currently
  # in LMS and returns the number of those found for each event, zero included. All the API calls are
  # made before the database is touched, so a failure leaves existing data alone.
  def self.import(season_id, api: LmsApi.new)
    events = api.season_events(season_id).select { |e| EVENT_NAMES.include?(e["name"]) }
    missing = EVENT_NAMES - events.map { |e| e["name"] }
    raise ImportError, "Season #{season_id} has no event named #{missing.join(', ')}" if missing.any?

    rows = events.flat_map do |event|
      api.event_results(event["id"]).fetch("fixtures").select { |f| club_fixture?(f) }.map do |fixture|
        { season_id: season_id, event_id: event["id"], event_name: event["name"], fixture_id: fixture["fixture_id"] }
      end
    end
    raise ImportError, "Season #{season_id} has no #{CLUB} fixtures yet" if rows.empty?

    transaction do
      where(season_id: season_id).delete_all
      insert_all!(rows)
    end
    EVENT_NAMES.index_with { |name| rows.count { |r| r[:event_name] == name } }
  end

  def self.club_fixture?(fixture) = fixture.values_at("home_team", "away_team").any? { |team| team.to_s.start_with?(CLUB) }
  private_class_method :club_fixture?
end
