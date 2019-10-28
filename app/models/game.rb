class Game < ApplicationRecord
  include Constrainable
  include Pageable

  belongs_to :user, inverse_of: :games, optional: true

  DIFFICULTIES = %w/easy medium hard/;
  MAX_DIFFICULTY = 10
  MAX_TITLE = 64
  MAX_PGN = 10000

  before_validation :clean_and_parse_pgn, :do_title, :do_difficulty

  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_nil: true
  validates :pgn, presence: true, length: { maximum: MAX_PGN }
  validates :title, presence: { message: "could not be guessed" }, length: { maximum: MAX_TITLE }
  validate :check_pgn

  def self.search(matches, params, path, opt={})
    matches = matches.includes(:user)
    if params[:difficulty] == "games"
      matches = matches.where(difficulty: nil)
    elsif params[:difficulty] == "problems"
      matches = matches.where.not(difficulty: nil)
    elsif DIFFICULTIES.include?(params[:difficulty])
      matches = matches.where(difficulty: params[:difficulty])
    end
    if sql = cross_constraint(params[:query], %w{title pgn})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def self.clean(pgn)
    pgn = pgn.dup
    return pgn if pgn.blank?
    pgn.gsub!(/\r\n/, "\n")                      # convert line  endings
    pgn.gsub!(/\r/, "\n")                        # convert line  endings
    pgn.sub!(/\A[\n\s]+/, "")                    # remove leading space
    pgn.gsub!(/\][\n\s]*\[/, "]\n[")             # headers always start a new line
    pgn.sub!(/\][\n\s]*([^\[\n\s])/, "]\n\n\\1") # two new lines between last header and moves
    pgn.sub!(/[\n\s]{2,}\[.*\z/m, "\n")          # remove any games after the first
    pgn.sub!(/[\n\s]+\z/, "\n")                  # remove trailing space
    pgn
  end

  private

  def clean_and_parse_pgn
    self.pgn = Game.clean(pgn)
    begin
      games = PGN.parse(pgn)
      @game = games.first
    rescue Whittle::ParseError => e
      logger.error "PGN parse error (#{e.message})"
    rescue StandardError => e
      logger.error "PGN error (#{e.message})"
    end
  end

  def do_title
    if title.present?
      title.squish!
    elsif @game
      title = nil
      if problem?
        r = result
        if player == :white
          if r == "1-0" && mate?
            title = "White to play and mate in #{number_of_moves}"
          elsif r != "0-1"
            title = "White to play and #{r == '1-0' ? 'win' : 'draw'}"
          end
        else
          if r == "0-1" && mate?
            title = "Black to play and mate in #{number_of_moves}"
          elsif r != "1-0"
            title = "Black to play and #{r == '0-1' ? 'win' : 'draw'}"
          end
        end
      else
        w, b, e, y, r = tag("White"), tag("Black"), tag("Event"), year("Date"), result
        if w && b
          title = "#{w} - #{b}"
          title+= ", #{e}" if e
          title+= ", #{y}" if y
          title+= ", #{r}" if r
        end
      end
      self.title = title.squish.truncate(MAX_TITLE) if title.present?
    end
  end

  def do_difficulty
    if @game && problem?
      self.difficulty = "easy" unless DIFFICULTIES.include?(difficulty)
    else
      self.difficulty = nil
    end
  end

  def tag(name)
    val = @game.tags[name]
    return unless val.present?
    return unless val.match(/[a-z]/i)
    val.squish
  end

  def year(name)
    val = @game.tags[name]
    return unless val.present?
    return unless val.match(/\b([12]\d{3})\b/)
    $1
  end

  def result
    val = @game.result
    return unless val.present?
    val = "½-½" if val == "1/2-1/2"
    return unless %w/1-0 0-1 ½-½/.include?(val)
    val
  end

  def player
    @game.positions.first.player
  end

  def mate?
    @game.moves.last.to_s.match(/#/)
  end

  def problem?
    @game.positions.first.to_fen.to_s != PGN::FEN::INITIAL
  end

  def number_of_moves
    @game.positions.last.fullmove - @game.positions.first.fullmove + 1
  end

  def check_pgn
    errors.add(:pgn, "unparsable") unless @game
  end
end
