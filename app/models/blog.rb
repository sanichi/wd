class Blog < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  belongs_to :user, inverse_of: :blogs, optional: true

  FEN1 = /\n*\s*(FEN\s*"[^"]*")\s*\n*/
  FEN2 = /\AFEN\s*"([^"]*)"\z/
  TABLE = /(?:\A|\n)_TABLE([a-z0-9]*)_(\z|\n)/
  MAX_SLUG = 25
  MAX_TITLE = 50
  MAX_TAG = 12
  TAGS = %w/ateam bteam cteam sncl spens/
  VALID_SLUG = /\A[a-z][a-z0-9_]+\z/

  before_validation :normalize_attributes

  validates :summary, presence: true
  validates :tag, inclusion: { in: TAGS }, allow_nil: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }
  validates :slug,
    length: { maximum: MAX_SLUG },
    format: { with: VALID_SLUG },
    uniqueness: true,
    allow_nil: true

  scope :by_id,       -> { order(:id) }
  scope :created_des, -> { order(created_at: :desc) }
  scope :created_asc, -> { order(created_at: :asc) }
  scope :updated_des, -> { order(updated_at: :desc) }
  scope :updated_asc, -> { order(updated_at: :asc) }

  def self.search(matches, params, path, opt={})
    matches = matches.includes(:user)
    matches =
      case params[:order]
      when "created_des" then matches.created_des
      when "created_asc" then matches.created_asc
      when "updated_des" then matches.updated_des
      when "updated_asc" then matches.updated_asc
      else matches.created_des
      end
    if sql = cross_constraint(params[:query], %w{title summary story})
      matches = matches.where(sql)
    end
    if (user_id = params[:user_id].to_i) > 0
      matches = matches.where(user_id: user_id)
    end
    paginate(matches, params, path, opt)
  end

  def summary_html
    to_html(with_table(summary))
  end

  def story_html
    html = []
    fens = {}
    html.push summary_html
    return [html, fens] unless story.present?
    fen_id = 0
    parts = with_table(story).split(FEN1)
    parts.each do |p|
      if p.present?
        if p.match(FEN2)
          fens[fen_id] = $1
          html.push "FEN__#{fen_id}"
          fen_id += 1
        else
          html.push to_html(p)
        end
      end
    end
    [html, fens]
  end

  def to_param
    slug || id.to_s
  end

  def to_s # for rspec tests
    "blog"
  end

  private

  def normalize_attributes
    self.slug = nil if slug.blank?
    title&.squish!
    self.summary = clean(summary)
    self.story = clean(story)
    self.tag = nil if tag.blank?
  end

  def clean(markdown)
    return nil if markdown.blank?
    markdown.strip!
    markdown.gsub!(/\r\n/, "\n")
    markdown.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    markdown.gsub!(/\[([^\[]+)\]\(https?:\/\/(?:www\.)?wanderingdragonschess.club\/?(.*)\)/, "[\\1](/\\2)")
    markdown = markdown.use_halves
    markdown
  end

  def with_table(text)
    if m = text.match(TABLE)
      table = Table.new(self, m[1])
      text.sub(TABLE, table.markdown)
    else
      text
    end
  end
end
