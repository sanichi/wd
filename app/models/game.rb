class Game < ApplicationRecord
  include Constrainable
  include Pageable

  belongs_to :user, inverse_of: :games, optional: true

  MAX_TITLE = 64
  MAX_PGN = 10000

  before_validation :normalize_attributes, :guess_title

  validates :pgn, presence: true, length: { maximum: MAX_PGN }
  validates :title, presence: true, length: { maximum: MAX_TITLE }
  validate :check_pgn

  def self.search(matches, params, path, opt={})
    matches = matches.includes(:user)
    if sql = cross_constraint(params[:query], %w{title pgn})
      matches = matches.where(sql)
    end
    paginate(matches, params, path, opt)
  end

  def self.clean(pgn)
    return if pgn.blank?
    pgn.gsub!(/\r\n/, "\n")
    pgn.gsub!(/\r/, "\n")
    pgn.sub!(/\A[\s\n]+/, "")
    return unless pgn.match(/\A((?:[^\n\s][^\n]*\n)+)\n+((?:[^\n\s][^\n]*\n)+)/)
    "#{$1}\n#{$2}"
  end

  private

  def normalize_attributes
    @clean = Game.clean(pgn)
    if @clean
      self.pgn = @clean
      begin
        @parse = PGN.parse(@clean)
        @first = @parse.first
      rescue Whittle::ParseError => e
        logger.error "PGN parse error (#{e.message})"
      rescue StandardError => e
        logger.error "PGN error (#{e.message})"
      end
    end
    title&.squish!
    guess_title if title.blank?
  end

  def guess_title
    return unless @first
    white = @first.tags["White"]
    white = "Unknown" if white.blank? || !white.match(/[a-z]/i)
    black = @first.tags["Black"]
    black = "Unknown" if black.blank? || !black.match(/[a-z]/i)
    year = $1 if @first.tags["Date"]&.match(/(\d{4})/)
    self.title = "#{white} - #{black}#{year ? ', ' : ''}#{year}".truncate(MAX_TITLE)
  end

  def check_pgn
    if !@clean
      errors.add(:pgn, "invalid")
    elsif !@first
      errors.add(:pgn, "unparsable")
    end
  end
end
