class Table
  RESULT = /
    (?<=\n|\A)\s*                                      # starts with a new line or string start
    (?:\||\*)                                          # start of table row or list item
    ([^|\n]+)                                          # white player, possibly with extra white space
    (?:\||,)\s*                                        # separates first name from result
    \[?(1-0|0-1|½-½|\?-\?)(?:\]\(\/games\/\d+\))?      # result, possibly linked to game
    \s*(?:\||,)                                        # separates result from black player
    ([^|\n]+)                                          # black player, possibly with extra white space
    \|?                                                # signifies end of table row
    \s*(?=\n|\z)                                       # ends with new line or string end
  /x

  Player = Struct.new(:name, :games, :points, :tb) do
    def pt_score(pts=points)
      frac = pts % 2 == 1 ? "½" : ""
      if pts < 2 && frac.present?
        frac
      else
        "#{pts/2}#{frac}"
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
    @break = !options.include?("t")
    @cross = options.include?("x")
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
    headers.push ["TB", ":-:"] if @break
    headers.push ["G", ":-:"] if @games
    @players.each_with_index { |p, i| headers.push [i + 1, ":-:"] } if @cross
    lines.push "|" + headers.map(&:first).join("|") + "|"
    lines.push "|" + headers.map(&:last).join("|") + "|"

    @players.each_with_index do |p, i|
      line = []
      line.push i + 1
      line.push p.name
      line.push "__#{p.pt_score}__"
      line.push p.tb_score if @break
      line.push p.games if @games
      if @cross
        @players.each do |q|
          scores = @rhash[p.name][q.name]
          if scores && !scores.empty?
            line.push q.pt_score(scores.sum)
          else
            line.push " "
          end
        end
      end
      lines.push "|" + line.join("|") + "|"
    end

    lines.push ""
    lines.push ""
    lines.join "\n"
  end

  private

  def result_hash
    @rhash = {}
    @text.scan(RESULT) do |white, result, black|
      white.sub!(/\(.*\)/, "")
      white.squish!
      black.sub!(/\(.*\)/, "")
      black.squish!
      if white.present? && black.present? && white != black
        @rhash[white] ||= {}
        @rhash[black] ||= {}
        @rhash[white][black] ||= []
        @rhash[black][white] ||= []
        case result
        when "1-0"
          @rhash[white][black].push 2
          @rhash[black][white].push 0
        when "0-1"
          @rhash[white][black].push 0
          @rhash[black][white].push 2
        when "½-½"
          @rhash[white][black].push 1
          @rhash[black][white].push 1
        end
      end
    end
  end

  def player_hash
    @phash = @rhash.each_with_object({}) do |(name, scores), hash|
      games = scores.values.map(&:length).sum
      points = scores.values.map(&:sum).sum
      hash[name] = Player.new(name, games, points, 0)
    end
  end

  def tie_breakers
    @phash.keys.each do |name|
      @phash[name].tb =
        @rhash[name].reduce(0) do |sum, (opponent, scores)|
          sum += scores.sum * @phash[opponent].points
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
