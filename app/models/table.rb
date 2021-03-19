class Table
  RESULT = /\|([^|]+)\|[^|]*(1-0|0-1|½-½)[^|]*\|([^|]+)\|\s*(?:\n|\z)/
  Player = Struct.new(:name, :games, :points, :tb) do
    def score
      "#{points/2}#{points%2 == 1 ? '½' : ''}"
    end

    def tbf
      frac =
        case tb % 4
        when 1 then "¼"
        when 2 then "½"
        when 3 then "¾"
        else ""
        end
      "#{tb/4}#{frac}"
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
    lines.push "|#|Player|P|G|TB|"
    lines.push "|:-:|---|:-:|:-:|:-:|"
    @players.each_with_index { |p, i| lines.push "|#{i+1}|#{p.name}|__#{p.score}__|#{p.games}|#{p.tbf}|" }
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
      hash[name] = Player.new(name, games, points, 0)
    end
  end

  def tie_breakers
    @phash.keys.each do |name|
      @phash[name].tb =
        @rhash[name].reduce(0) do |sum, (opponent, score)|
          case score
          when 2
            sum += @phash[opponent].points * 2
          when 1
            sum += @phash[opponent].points
          else
            sum
          end
        end
    end
  end

  def ordered_players
    @players = @phash.values.sort do |a, b|
      primary = b.points <=> a.points
      if primary == 0
        secondary = b.tb <=> a.tb
        if secondary == 0
          a.name <=> b.name
        else
          secondary
        end
      else
        primary
      end
    end
  end
end
