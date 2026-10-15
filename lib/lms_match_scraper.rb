require_relative "misc/chess_match_scraper"

# Fetches the result of one Edinburgh league match from the LMS API. The
# fixture ID is mapped to its event by LmsFixture (see the lms:fixtures rake
# task), then the results for the whole event are fetched and the fixture picked
# out. Returns the same hash as the other match scrapers.
class LmsMatchScraper
  RESULTS = {
    "home_win"         => "1 - 0",
    "away_win"         => "0 - 1",
    "draw"             => "½ - ½",
    "home_default_win" => "1 * 0",
    "away_default_win" => "0 * 1",
    "double_default"   => "0 * 0",
    # Placeholders for the editor to replace, as the API doesn't say who won.
    "adjourned"        => "adj",
    "adjudicated"      => "adjud",
  }.freeze
  NOT_RECORDED = "N"

  attr_reader :fixture_id

  def initialize(fixture_id, api: nil)
    @fixture_id = fixture_id.to_i
    @api = api
  end

  def scrape
    entry = LmsFixture.find_by(fixture_id: fixture_id)
    unless entry
      raise ChessMatchScraper::UnknownFixtureError,
        "Unknown fixture: check the ID is right, otherwise the webmaster needs to load this season's fixtures"
    end
    fixture = api.event_results(entry.event_id).fetch("fixtures").find { |f| f["fixture_id"] == fixture_id }
    raise ChessMatchScraper::ParseError, "Fixture not found in the #{entry.event_name} results" unless fixture
    match_data(fixture)
  rescue ChessMatchScraper::ScraperError
    raise
  rescue LmsApi::Error => e
    raise ChessMatchScraper::NetworkError, "Failed to fetch: #{e.message}"
  rescue KeyError, TypeError, NoMethodError => e
    raise ChessMatchScraper::ParseError, "Failed to parse: #{e.message}"
  end

  private

  def api = @api ||= LmsApi.new

  def match_data(fixture)
    games = fixture.fetch("games")
    if games.empty? || games.all? { |g| g["result"].nil? }
      raise ChessMatchScraper::MatchNotPlayedError, "Match has not been played yet"
    end
    home_team, away_team = fixture["home_team"], fixture["away_team"]
    raise ChessMatchScraper::ParseError, "Team names missing" if home_team.blank? || away_team.blank?

    {
      home_team:  home_team,
      away_team:  away_team,
      home_score: fixture.fetch("home_score").to_f,
      away_score: fixture.fetch("away_score").to_f,
      games:      games.map { |game| game_data(game) },
    }
  end

  def game_data(game)
    {
      board:       game.fetch("board"),
      home_player: game.dig("home_player", "name"),
      home_rating: rating(game["home_player"]),
      result:      result(game),
      away_player: game.dig("away_player", "name"),
      away_rating: rating(game["away_player"]),
    }
  end

  def result(game)
    code = game["result"]
    return NOT_RECORDED if code.nil?
    RESULTS.fetch(code) { raise ChessMatchScraper::ParseError, "Board #{game['board']} has an unrecognised result: #{code}" }
  end

  def rating(player)
    rating = player && player["rating"]
    rating.to_i > 0 ? rating.to_i : nil
  end
end
