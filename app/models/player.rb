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
    president treasurer
    captain_el1 captain_el2 captain_el3
    captain_nl1 captain_nl2
    captain_r captain_s
    captain_al1 captain_al2
     webmaster/
  OTHER_ROLES = %w/
    player_el1 player_el2 player_el3
    player_nl1 player_nl2
    player_r player_s
    player_al1 player_al2
    member/
  ROLES = PRINCIPLE_ROLES + OTHER_ROLES
  TITLES = %w/GM IM FM CM WGM WIM WFM WCM/
  RANK = ROLES.each_with_object({}).each_with_index{ |(r, h), i| h[r] = i }

  before_validation :normalize_attributes

  validates :email, format: { with: /\A[^\s@]+@[^\s@]+\z/ }, length: { maximum: MAX_EMAIL }, uniqueness: true, allow_nil: true
  validates :federation, format: { with: /[A-Z]{3}\z/ }
  validates :fide_id, :sca_id, numericality: { only_integer: true, minimum: MIN_ID }, uniqueness: true, allow_nil: true
  validates :fide_rating, :sca_rating, numericality: { only_integer: true, minimum: MIN_RATING, maximum: MAX_RATING }, allow_nil: true
  validates :first_name, length: { maximum: MAX_NAME }, format: { with: /\A[A-Z][a-z]+\z/ }, uniqueness: { scope: :last_name }
  validates :last_name, length: { maximum: MAX_NAME }, format: { with: /\A(O'|Mac|Mc)?[A-Z][a-z]+\z/ }
  validates :phone, length: { maximum: MAX_PHONE }, format: { with: /\A\d+( \d+)*\z/ }, allow_nil: true
  validates :title, inclusion: { in: TITLES }, allow_nil: true
  validate :roles_rules

  scope :by_name,   -> { order(:first_name, :last_name) }
  scope :by_rank,   -> { order(:rank) }
  scope :by_rating, -> { order(Arel.sql("COALESCE(sca_rating, fide_rating) DESC NULLS LAST, first_name, last_name")) }

  def self.search(players, params)
    if params[:order] == "name"
      players = players.by_name
    else
      players = players.by_rating
    end
    if sql = cross_constraint(params[:name], %w{first_name last_name})
      players = players.where(sql)
    end
    role = params[:role].to_s
    if role == "captain"
      sql = ROLES.select { |r| r.match?(/\Acaptain/) }.map { |r| "'#{r}' = ANY (roles)" }.join(" OR ")
      players = players.where(sql)
    elsif role.match(/\Aplayer_(\w+)\z/)
      players = players.where("'player_#{$1}' = ANY (roles) OR 'captain_#{$1}' = ANY (roles)")
    elsif ROLES.include?(role) && role != "member"
      players = players.where("'#{role}' = ANY (roles)")
    end
    players
  end

  def principle_roles
    biggies = roles.select { |role| PRINCIPLE_ROLES.include?(role) }
    biggies.push("member") if biggies.empty?
    biggies
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
    superfluous = roles.map { |role| role.match(/\Acaptain_(\w+)\z/) ? "player_#{$1}" : nil }.compact
    self.roles.reject! { |role| superfluous.include?(role) }
    self.roles.sort_by! { |role| RANK[role] }
    self.roles.reject! { |role| role == "member" } if roles.include?("member") && roles.length > 1
    self.rank = RANK[roles.first]
  end
end
