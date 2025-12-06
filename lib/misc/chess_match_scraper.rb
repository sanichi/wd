require 'mechanize'

class ChessMatchScraper
  class ScraperError < StandardError; end
  class NetworkError < ScraperError; end
  class ParseError < ScraperError; end
  class MatchNotPlayedError < ScraperError; end

  attr_reader :agent

  def initialize(agent: nil)
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
    raise NetworkError, "Failed to fetch: #{response_code} #{response_text}"
  rescue Mechanize::Error, SocketError, Timeout::Error => e
    raise NetworkError, "Failed to fetch: #{e.message}"
  rescue ScraperError
    raise
  rescue StandardError => e
    raise ParseError, "Failed to parse: #{e.message}"
  end

  private

  def fetch_page
    raise NotImplementedError, "Subclasses must implement fetch_page"
  end

  def parse_match_data(page)
    raise NotImplementedError, "Subclasses must implement parse_match_data"
  end
end

class LmsMatchScraper < ChessMatchScraper
  BASE_URL = 'https://www.lms.playchess.org.uk/fixture'

  attr_reader :fixture_id

  def initialize(fixture_id, agent: nil)
    super(agent: agent)
    @fixture_id = fixture_id
  end

  private

  def fetch_page
    @agent.get("#{BASE_URL}/#{fixture_id}")
  end

  def parse_match_data(page)
    table = page.at('table.team-match-table')
    raise ChessMatchScraper::ParseError, "Match table not found" unless table

    rows = table.css('tbody tr')
    raise ChessMatchScraper::ParseError, "No match data found" if rows.empty?

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
    # Handle the result, including defaults: convert "1 - 0(def)" to "1 * 0", etc.
    result = cells[3].text.strip
    if result.end_with?('(def)')
      result = result.sub(/\(def\)\z/, '').strip  # Remove (def)
      result = result.sub(/-/, '*')               # Replace dash with asterisk (preserving spaces)
    end

    {
      board: cells[0].text.strip.to_i,
      home_rating: extract_rating(cells[1]),
      home_player: extract_player_name(cells[2]),
      result: result,
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
      raise ChessMatchScraper::MatchNotPlayedError, "Match has not been played yet"
    end
  end

  def calculate_score(games, side)
    games.sum do |game|
      result = game[:result]

      # Handle results: both normal (1-0) and defaults (1*0)
      # Check if result starts with the score pattern
      if result =~ /^1\s*[-*]\s*0/
        side == :home ? 1.0 : 0.0
      elsif result =~ /^0\s*[-*]\s*1/
        side == :away ? 1.0 : 0.0
      elsif result =~ /^(½\s*[-*]\s*½|0\.5\s*[-*]\s*0\.5)/
        0.5
      else
        0.0
      end
    end
  end
end

class SnclMatchScraper < ChessMatchScraper
  attr_reader :url

  def initialize(url_fragment, agent: nil)
    super(agent: agent)
    @url = parse_and_build_url(url_fragment)
  end

  private

  def fetch_page
    @agent.get(@url)
  end

  def parse_and_build_url(fragment)
    # Extract components from the URL fragment
    server_match = fragment.match(/(s\d+)\.chess-results\.com/)
    server = server_match ? server_match[1] : 's1'

    tournament_match = fragment.match(/tnr(\d+)\.aspx/)
    raise ChessMatchScraper::ParseError, "Tournament ID not found in URL" unless tournament_match
    tournament_id = tournament_match[1]

    art_match = fragment.match(/art=(\d+)/)
    raise ChessMatchScraper::ParseError, "art parameter not found in URL" unless art_match
    art = art_match[1]

    rd_match = fragment.match(/rd=(\d+)/)
    raise ChessMatchScraper::ParseError, "rd parameter not found in URL" unless rd_match
    rd = rd_match[1]

    lan_match = fragment.match(/lan=(\d+)/)
    lan = lan_match ? lan_match[1] : '1'

    snode_match = fragment.match(/Snode=(S\d+)/i)
    snode = snode_match ? snode_match[1] : 'S0'

    "https://#{server}.chess-results.com/tnr#{tournament_id}.aspx?lan=#{lan}&art=#{art}&rd=#{rd}&Snode=#{snode}"
  end

  def parse_match_data(page)
    # Find all match header rows
    match_headers = page.search('tr.CRg1b')

    # Find the first match with "Wandering Dragons"
    match_row = match_headers.find { |row| row.text.include?('Wandering Dragons') }

    unless match_row
      raise ChessMatchScraper::ParseError, "Team 'Wandering Dragons' not found on page - please check the URL is correct"
    end

    # Extract team names and match score from header
    cells = match_row.css('th')

    # Structure: Bo. | board_num | team1 | Rtg | - | board_num | team2 | Rtg | score
    home_team = cells[2].text.strip
    away_team = cells[6].text.strip
    match_score = cells[8].text.strip  # e.g., "3 : 2"

    # Parse individual games until we hit another match header or run out of rows
    games = []
    current_row = match_row.next_element

    while current_row
      # Stop if we've hit another match header
      break if current_row['class']&.include?('CRg1b')

      # Only parse rows that look like game rows (CRg1 or CRg2)
      if current_row['class']&.match?(/CRg[12]/)
        game = parse_game_row(current_row)
        games << game if game
      end

      current_row = current_row.next_element
    end

    {
      home_team: home_team,
      away_team: away_team,
      games: games,
      home_score: calculate_score(games, :home),
      away_score: calculate_score(games, :away)
    }
  end

  def parse_game_row(row)
    # Use xpath to get only direct td children, not nested ones
    cells = row.xpath('./td')
    return nil if cells.empty? || cells.length < 9

    # Cell structure:
    # 0: board (e.g., "5.1")
    # 1: home title (optional)
    # 2: home player name (nested table)
    # 3: home rating
    # 4: separator "-"
    # 5: away title (optional)
    # 6: away player name (nested table)
    # 7: away rating
    # 8: result

    board = cells[0].text.strip.split('.').last.to_i  # "5.1" -> 1

    home_rating = extract_rating_with_title(cells[3], cells[1])
    home_player = extract_player_name(cells[2])

    away_rating = extract_rating_with_title(cells[7], cells[5])
    away_player = extract_player_name(cells[6])

    result = parse_result(cells[8].text.strip)

    {
      board: board,
      home_rating: home_rating,
      home_player: home_player,
      result: result,
      away_player: away_player,
      away_rating: away_rating
    }
  end

  def extract_rating_with_title(rating_cell, title_cell)
    rating = rating_cell.text.strip
    return nil if rating.empty?

    title = title_cell.text.strip

    if title.empty?
      rating
    else
      "#{rating} #{title}"
    end
  end

  def extract_player_name(cell)
    # Player name is in a nested table with an <a> link or plain text
    link = cell.at('a')
    if link
      link.text.strip
    else
      # Extract text, skipping the nested table structure
      cell.text.strip
    end
  end

  def parse_result(result_text)
    # Convert SNCL default notation to standard format
    case result_text
    when /^\+\s*-\s*-$/
      '1 * 0'  # Home default win
    when /^-\s*-\s*\+$/
      '0 * 1'  # Away default win
    else
      result_text  # Normal results like "1 - 0", "0 - 1", "½ - ½"
    end
  end

  def calculate_score(games, side)
    games.sum do |game|
      result = game[:result]

      # Handle results: both normal (1-0) and defaults (1*0)
      if result =~ /^1\s*[-*]\s*0/
        side == :home ? 1.0 : 0.0
      elsif result =~ /^0\s*[-*]\s*1/
        side == :away ? 1.0 : 0.0
      elsif result =~ /^(½\s*[-*]\s*½|0\.5\s*[-*]\s*0\.5)/
        0.5
      else
        0.0
      end
    end
  end
end
