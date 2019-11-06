class Book < ApplicationRecord
  include Constrainable
  include Pageable

  CATEGORIES = %w{opening ending middle tournament match game biography puzzle training other}
  MAX_AUTHOR = 60
  MAX_BORROWERS = 200
  MAX_CATEGORY = 10
  MAX_COPIES = 127
  MAX_MEDIUM = 10
  MAX_NOTE = 100
  MAX_TITLE = 100
  MEDIA = %w{book cd}
  MIN_YEAR = 1800

  before_validation :normalize_attributes

  validates :author, length: { maximum: MAX_AUTHOR }, presence: true
  validates :borrowers, length: { maximum: MAX_BORROWERS }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :copies, numericality: { integer_only: true, greater_than_or_equal_to: 1, less_than_or_equal_to: MAX_COPIES }
  validates :medium, inclusion: { in: MEDIA }
  validates :note, length: { maximum: MAX_NOTE }, allow_nil: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }, uniqueness: { scope: :author }
  validates :year, numericality: { integer_only: true, greater_than_or_equal_to: MIN_YEAR, less_than_or_equal_to: Date.today.year }

  scope :by_author, -> { order(:author, :year, :title) }
  scope :by_title,  -> { order(:title, :year, :author) }
  scope :by_year,   -> { order(year: :desc, title: :asc, author: :asc) }

  def self.search(matches, params, path, opt={})
    matches = case params[:order]
    when "author" then matches.by_author
    when "title"  then matches.by_title
    else               matches.by_year
    end
    if sql = cross_constraint(params[:query], [:author, :title, :note])
      matches = matches.where(sql)
    end
    if params[:borrower]&.match?(/\A\s*ALL\s*\z/)
      matches = matches.where.not(borrower: nil)
    elsif sql = cross_constraint(params[:borrowers], [:borrowers])
      matches = matches.where(sql) if sql = cross_constraint(params[:borrower], [:borrower])
    end
    matches = matches.where(medium: params[:medium]) if params[:medium].present?
    matches = matches.where(category: params[:category]) if params[:category].present?
    paginate(matches, params, path, opt)
  end

  def to_s # for rspec tests
    "book"
  end

  private

  def normalize_attributes
    title&.squish!
    author&.squish!
    borrowers&.squish!
    note&.squish!
    self.borrowers = nil unless borrowers.present?
    self.note = nil unless note.present?
  end
end
