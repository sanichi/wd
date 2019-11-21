class Game < ApplicationRecord
  include Constrainable
  include Pageable

  belongs_to :user, inverse_of: :games, optional: true

  DIFFICULTIES = %w/easy medium hard/
  MAX_DIFFICULTY = 10
  MAX_TITLE = 64
  MAX_PGN = 10000

  before_validation :clean_and_parse_pgn, :do_title, :do_difficulty

  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_nil: true
  validates :pgn, presence: true, length: { maximum: MAX_PGN }
  validates :title, presence: { message: "could not be guessed" }, length: { maximum: MAX_TITLE }
  validate :check_pgn

  default_scope { order(created_at: :desc) }

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

  def study?
    difficulty.present?
  end

  def fen
    @fen ||= pgn.match(/\[FEN\s+"([^"]+)"\s*\]/) ? $1 : ""
  end

  def result
    @result ||= pgn.match(/\[Result\s+"([^"]+)"\s*\]/) ? $1 : ""
  end

  def to_play
    if fen.present?
      fen.match?(/ w /) ? "white" : "black"
    else
      "white"
    end
  end

  def orientation
    if difficulty
      to_play
    else
      if result == "0-1"
        "black"
      else
        "white"
      end
    end
  end

  def to_s # for rspec tests
    "game"
  end

  def moves
    PgnGame.new(pgn).html
  end

  private

  def clean_and_parse_pgn
    self.pgn = PgnGame.clean(pgn)
    @game = PgnGame.new(pgn).game
  end

  def do_title
    if title.present?
      title.squish!
    elsif @game
      title = nil
      if problem?
        r = pgn_result
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
        w, b, e, y, r = surname("White"), surname("Black"), tag("Event"), year("Date"), pgn_result
        if w && b
          title = "#{w}-#{b}"
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

  def surname(colour)
    name = tag(colour)
    if name.nil? || name.match?(/\A\s*\??\s*\z/)
      "Unknown"
    elsif name.match(/\A([^,]+),[^,]+\z/)
      $1.squish
    elsif name.match(/\A[^,]+\s([^,\s]+)\z/)
      $1.squish
    else
      name.squish
    end
  end

  def year(name)
    val = @game.tags[name]
    return unless val.present?
    return unless val.match(/\b([12]\d{3})\b/)
    $1
  end

  def pgn_result
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
