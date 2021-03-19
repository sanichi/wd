class Table
  RESULT = /\|([^|]+)\|[^|]*(1-0|0-1|½-½)[^|]*\|([^|]+)\|\s*(?:\n|\z)/
  Player = Struct.new(:name, :games, :points, :tb) do
    def score
      "#{points/2}#{points%2 == 1 ? '½' : ''}"
    end
  end

  def initialize(blog)
    @text = blog.summary + blog.story
    result_hash
    player_hash
    tie_breakers
    ordered_players
  end

  def markdown
    lines = []
    lines.push ""
    lines.push ""
    lines.push "|#|Player|Pts|TB|"
    lines.push "|:-:|---|:-:|:-:|"
    @players.each_with_index { |p, i| lines.push "|#{i+1}|#{p.name}|#{p.score}/#{p.games}|#{'%.1f' % p.tb}|" }
    lines.push ""
    lines.push ""
    lines.join "\n"
  end

  private

  def result_hash
    @rhash = Hash.new { |h,k| h[k] = Hash.new(0) }
    @text.scan(RESULT) do |white, result, black|
      white.sub!(/\(.*\)/, "")
      white.squish!
      black.sub!(/\(.*\)/, "")
      black.squish!
      Rails.logger.debug("#{white}-#{black}-#{result}") if white == "Donkin, A." || black == "Donkin, A."
      if white.present? && black.present? && white != black
        @rhash[white][black] += (result == '1-0' ? 2 : (result == '0-1' ? 0 : 1))
        @rhash[black][white] += (result == '0-1' ? 2 : (result == '1-0' ? 0 : 1))
      end
    end
  end

  def player_hash
    @phash = @rhash.each_with_object({}) do |(name, scores), hash|
      games = scores.values.length
      points = scores.values.sum
      hash[name] = Player.new(name, games, points, 0.0)
    end
  end

  def tie_breakers
    @phash.keys.each do |name|
      @phash[name].tb =
        @rhash[name].reduce(0.0) do |sum, (opponent, score)|
          case score
          when 2
            sum += @phash[opponent].points / 2.0
          when 1
            sum += @phash[opponent].points / 4.0
          else
            sum
          end
        end
    end
  end

  def ordered_players
    @players = @phash.values.sort do |a, b|
      primary = b.points <=> a.points
      primary == 0 ? b.tb <=> a.tb : primary
    end
  end
end
