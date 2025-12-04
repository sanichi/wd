require 'mechanize'

class ChessMatchScraper
  BASE_URL = 'https://www.lms.playchess.org.uk/fixture'

  class ScraperError < StandardError; end
  class NetworkError < ScraperError; end
  class ParseError < ScraperError; end
  class MatchNotPlayedError < ScraperError; end

  attr_reader :fixture_id, :agent

  def initialize(fixture_id, agent: nil)
    @fixture_id = fixture_id
    @agent = agent || Mechanize.new
  end

  def scrape
    page = fetch_page
    parse_match_data(page)
  rescue Mechanize::ResponseCodeError => e
    # Handle HTTP errors (404, 500, etc) with a clean message
    response_code = e.response_code.to_i
    response_text = case response_code
                    when 404 then 'Not Found'
                    when 403 then 'Forbidden'
                    when 500 then 'Internal Server Error'
                    when 502 then 'Bad Gateway'
                    when 503 then 'Service Unavailable'
                    else 'Error'
                    end
    raise NetworkError, "Failed to fetch fixture #{fixture_id}: #{response_code} #{response_text}"
  rescue Mechanize::Error, SocketError, Timeout::Error => e
    raise NetworkError, "Failed to fetch fixture #{fixture_id}: #{e.message}"
  rescue ScraperError
    raise
  rescue StandardError => e
    raise ParseError, "Failed to parse fixture #{fixture_id}: #{e.message}"
  end

  private

  def fetch_page
    @agent.get("#{BASE_URL}/#{fixture_id}")
  end

  def parse_match_data(page)
    table = page.at('table.team-match-table')
    raise ParseError, "Match table not found" unless table

    rows = table.css('tbody tr')
    raise ParseError, "No match data found" if rows.empty?

    games = []
    rows.each do |row|
      cells = row.css('td')
      next if cells.empty?

      # Check if this is a totals row
      if cells[0].text.strip.downcase == 'total'
        break
      end

      # Skip if we don't have enough cells for a game row
      next if cells.length < 6

      game = parse_game_row(cells)
      games << game if game
    end

    validate_match_played!(games)

    {
      home_team: extract_team_name(table, :home),
      away_team: extract_team_name(table, :away),
      games: games,
      home_score: calculate_score(games, :home),
      away_score: calculate_score(games, :away)
    }
  end

  def parse_game_row(cells)
    {
      board: cells[0].text.strip.to_i,
      home_rating: extract_rating(cells[1]),
      home_player: extract_player_name(cells[2]),
      result: cells[3].text.strip,
      away_player: extract_player_name(cells[4]),
      away_rating: extract_rating(cells[5])
    }
  end

  def extract_rating(cell)
    text = cell.text.strip
    return nil if text.empty?
    rating = text.to_i
    rating > 0 ? rating : nil
  end

  def extract_player_name(cell)
    # Remove any div elements (like membership indicators) from the cell
    cell.css('div').remove

    # Extract text from the cell, handling links
    link = cell.at('a')
    if link
      link.text.strip
    else
      cell.text.strip
    end
  end

  def extract_team_name(table, side)
    # Extract team names from thead columns
    # Format: Board | Rating | Home Team | V | Away Team | Rating
    thead = table.at('thead')
    return nil unless thead

    headers = thead.css('th').map { |th| th.text.strip }
    return nil if headers.length < 5

    # Column 2 is home team, column 4 is away team
    side == :home ? headers[2] : headers[4]
  end

  def validate_match_played!(games)
    return if games.empty?

    # Check if all results are "N" (not played)
    # Note: blank player names are allowed as they may indicate defaults/forfeits
    all_results_n = games.all? { |game| game[:result] == 'N' }

    if all_results_n
      raise MatchNotPlayedError, "Match #{fixture_id} has not been played yet"
    end
  end

  def calculate_score(games, side)
    games.sum do |game|
      result = game[:result]

      # Handle results that may have annotations like "(def)"
      # Check if result starts with the score pattern
      if result =~ /^1\s*-\s*0/
        side == :home ? 1.0 : 0.0
      elsif result =~ /^0\s*-\s*1/
        side == :away ? 1.0 : 0.0
      elsif result =~ /^(½\s*-\s*½|0\.5\s*-\s*0\.5)/
        0.5
      else
        0.0
      end
    end
  end
end
