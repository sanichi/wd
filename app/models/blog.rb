class Blog < ApplicationRecord
  include Constrainable
  include Pageable
  include Remarkable

  MAX_TITLE = 50

  before_validation :normalize_attributes

  validates :summary, presence: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  scope :created_des, -> { order(created_at: :desc) }
  scope :created_asc, -> { order(created_at: :asc) }
  scope :updated_des, -> { order(updated_at: :desc) }
  scope :updated_asc, -> { order(updated_at: :asc) }

  def self.search(params, path, opt={})
    matches =
      case params[:order]
      when "created_des" then created_des
      when "created_asc" then created_asc
      when "updated_des" then updated_des
      when "updated_asc" then updated_asc
      else created_des
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

  private

  def normalize_attributes
    title&.squish!
    summary&.strip!
    summary&.gsub!(/\r\n/, "\n")
    summary&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    if story.blank?
      self.story = nil
    else
      story&.strip!
      story.gsub!(/\r\n/, "\n")
      story.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
    end
  end
end
