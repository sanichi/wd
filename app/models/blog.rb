class Blog < ApplicationRecord
  MAX_TITLE = 50

  before_validation :normalize_attributes

  validates :story, presence: true
  validates :title, presence: true, length: { maximum: MAX_TITLE }

  private

  def normalize_attributes
    title&.squish!
    story&.gsub!(/\r\n/, "\n")
    story&.gsub!(/([^\S\n]*\n){2,}[^\S\n]*/, "\n\n")
  end
end
