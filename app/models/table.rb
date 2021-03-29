class Table
  RESULT = /\|([^|]+)\|[^|]*(1-0|0-1|½-½|\?-\?)[^|]*\|([^|]+)\|\s*(?:\n|\z)/

  Player = Struct.new(:name, :games, :points, :tb) do
    def pt_score
      frac = points % 2 == 1 ? "½" : ""
      if points < 2 && frac.present?
        frac
      else
        "#{points/2}#{frac}"
      end
    end

    def tb_score
      frac =
        case tb % 4
        when 1 then "¼"
        when 2 then "½"
        when 3 then "¾"
        else ""
        end
      if tb < 4 && frac.present?
        frac
      else
        "#{tb/4}#{frac}"
      end
    end
  end

  def initialize(blog, options)
    @text = blog.summary + blog.story
    @games = !options.include?("g")
    result_hash
    player_hash
    tie_breakers
    ordered_players
  end

  def markdown
    lines = []
    lines.push ""
    lines.push ""

    headers = []
    headers.push ["#", ":-:"]
    headers.push ["Player", "---"]
    headers.push ["P", ":-:"]
    headers.push ["G", ":-:"] if @games
    headers.push ["TB", ":-:"]
    lines.push "|" + headers.map(&:first).join("|") + "|"
    lines.push "|" + headers.map(&:last).join("|") + "|"

    @players.each_with_index do |p, i|
      line = []
      line.push i + 1
      line.push p.name
      line.push "__#{p.pt_score}__"
      line.push p.games if @games
      line.push p.tb_score
      lines.push "|" + line.join("|") + "|"
    end

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
        case result
        when "1-0"
          @rhash[white][black] += 2
          @rhash[black][white] += 0
        when "0-1"
          @rhash[white][black] += 0
          @rhash[black][white] += 2
        when "½-½"
          @rhash[white][black] += 1
          @rhash[black][white] += 1
        else
          @rhash[white] = Hash.new(0) if @rhash[white].empty?
          @rhash[black] = Hash.new(0) if @rhash[black].empty?
        end
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
