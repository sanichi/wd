class Player < ApplicationRecord
  include Constrainable

  MAX_EMAIL = 50
  MAX_FEDERATION = 3
  MAX_NAME = 20
  MAX_PHONE = 20
  MAX_RATING = 3000
  MAX_RANK = 127
  MAX_ROLE = 20
  MAX_TITLE = 3
  MIN_ID = 1
  MIN_RATING = 0
  PRINCIPLE_ROLES = %w/
    president treasurer webmaster
    captain_el1 captain_el2 captain_el3 captain_el4
    captain_nl1 captain_nl2
    captain_r captain_s/
  OTHER_ROLES = %w/
    player_el1 player_el2 player_el3 player_el4
    player_nl1 player_nl1
    player_r player_s
    member/
  ROLES = PRINCIPLE_ROLES + OTHER_ROLES
  TITLES = %w/GM IM FM CM WGM WIM WFM WCM/

  before_validation :normalize_attributes
  after_save :set_rank

  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: MAX_EMAIL }, uniqueness: true, allow_nil: true
  validates :federation, format: { with: /[A-Z]{3}\z/ }
  validates :fide_id, :sca_id, numericality: { only_integer: true, minimum: MIN_ID }, uniqueness: true, allow_nil: true
  validates :fide_rating, :sca_rating, numericality: { only_integer: true, minimum: MIN_RATING, maximum: MAX_RATING }, allow_nil: true
  validates :first_name, length: { maximum: MAX_NAME }, format: { with: /\A[A-Z][a-z]+\z/ }, uniqueness: { scope: :last_name }
  validates :last_name, length: { maximum: MAX_NAME }, format: { with: /\A(O'|Mac|Mc)?[A-Z][a-z]+\z/ }
  validates :phone, length: { maximum: MAX_PHONE }, format: { with: /\A\d+( \d+)*\z/ }, allow_nil: true
  validates :title, inclusion: { in: TITLES }, allow_nil: true
  validate :roles_rules

  def self.search(players, params)
    players = players.order("sca_rating DESC NULLS LAST, first_name, last_name")
    if sql = cross_constraint(params[:name], %w{first_name last_name})
      players = players.where(sql)
    end
    if ROLES.include?(params[:role]) && params[:role] != "member"
      players = players.where("'#{params[:role]}' = ANY (roles)")
    end
    players
  end

  def principle_roles
    roles.select { |role| PRINCIPLE_ROLES.include?(role) }
  end

  def name
    "#{first_name} #{last_name}"
  end

  def to_s # for rspec tests
    "player"
  end

  private

  def normalize_attributes
    email&.squish!
    federation&.squish!
    phone&.squish!
    first_name&.squish!
    last_name&.squish!
    self.email = nil if email.blank?
    self.phone = nil if phone.blank?
    self.title = nil if title.blank?
    self.contact = false if email.blank? && phone.blank?
    self.fide_rating = nil if fide_id.blank?
    self.sca_rating = nil if sca_id.blank?
  end

  def roles_rules
    self.roles = [] unless roles.is_a?(Array)
    self.roles.select! { |role| ROLES.include?(role) }
    self.roles = ["member"] if roles.empty?
    self.roles.uniq!
    self.roles.sort!
    self.roles.reject! { |role| role == "member" } if roles.include?("member") && roles.length > 1
  end

  def set_rank
    rank = MAX_RANK
    roles.each do |role|
      index = ROLES.index(role)
      rank = index if index && index < rank
    end
    update_column(:rank, rank)
  end
end