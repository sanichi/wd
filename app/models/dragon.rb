class Dragon < ApplicationRecord
  include Constrainable
  include Pageable

  MAX_FIRST_NAME = 15
  MAX_LAST_NAME = 20

  before_validation :canonicalize

  validates :first_name, presence: true, length: { maximum: MAX_FIRST_NAME }, uniqueness: { scope: :last_name, message: I18n.t("dragon.duplicate") }, format: { with: /\A[A-Z][a-z]+( [A-Z]){0,2}\z/ }
  validates :last_name, presence: true, length: { maximum: MAX_LAST_NAME }, format: { with: /\A(Mc|Mac|O')?[A-Z][a-z]+( [A-Z][a-z]+)*\z/ }

  scope :by_last_name,  -> { order(:last_name, :first_name) }
  scope :by_first_name, -> { order(:first_name, :last_name) }

  def name(reversed = false)
    nm = reversed ? "#{last_name}, #{first_name}" : "#{first_name} #{last_name}"
    nm.gsub!(" ", "\u00a0")
    nm
  end

  def self.search(matches, params, path, opt={})
    if (sql = cross_constraint(params[:name], %w(last_name first_name)))
      matches = matches.where(sql)
    end
    matches = matches.where(male: true)  if params[:gender] == "male"
    matches = matches.where(male: false) if params[:gender] == "female"
    matches = params[:order] == "first" ? matches.by_first_name : matches.by_last_name
    paginate(matches, params, path, opt)
  end

  private

  def canonicalize
    last_name&.squish!
    first_name&.squish!
  end
end
