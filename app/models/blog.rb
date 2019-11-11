class Blog < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  belongs_to :user, inverse_of: :blogs, optional: true

  MAX_SLUG = 25
  MAX_TITLE = 50
  VALID_SLUG = /\A[a-z][a-z0-9_]+\z/

  before_validation :normalize_attributes

  validates :summary, presence: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }
  validates :slug,
    length: { maximum: MAX_SLUG },
    format: { with: VALID_SLUG },
    uniqueness: true,
    allow_nil: true

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
    paginate(matches, params, path, opt)
  end

  def story_html
    if story.present?
      fst_half = summary.rstrip
      snd_half = story.lstrip
      to_html("#{fst_half}\n\n#{snd_half}")
    else
      summary_html
    end
  end

  def summary_html
    to_html(summary)
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
  end

  def clean(markdown)
    return nil if markdown.blank?
    markdown.strip!
    markdown.gsub!(/\r\n/, "\n")
    markdown.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    markdown.gsub!(/\[([^\[]+)\]\(https?:\/\/(?:www\.)?wanderingdragonschess.club\/?(.*)\)/, "[\\1](/\\2)")
    markdown
  end
end
