class User < ApplicationRecord
  has_secure_password

  MAX_NAME = 20
  MAX_HANDLE = 4
  MAX_ROLE = 20
  MIN_HANDLE = 2
  MIN_PASSWORD = 10
  ROLES = %w/guest member blogger librarian admin/.each do |role|
    define_method "#{role}?" do
      roles.include?(role)
    end
  end
  ALLOWED_ROLES = ROLES.reject { |role| role == "guest" }

  has_many :blogs, dependent: :nullify, inverse_of: :user

  before_validation :normalize_attributes

  validates :handle,
    format: { with: /\A[A-Z]+\z/, message: "is invalid (all caps)"},
    length: { minimum: MIN_HANDLE, maximum: MAX_HANDLE },
    uniqueness: true
  validates :first_name, format: { with: /\A[A-Z][a-z]+\z/ }
  validates :last_name, format: { with: /\A(O'|Mac|Mc)?[A-Z][a-z]+\z/ }
  validates :password, length: { minimum: MIN_PASSWORD }, allow_nil: true
  validate :roles_rules

  default_scope { order(:handle) }

  def name
    "#{first_name} #{last_name}"
  end

  def to_s # for rspec tests
    "user"
  end

  private

  def normalize_attributes
    first_name&.squish!
    last_name&.squish!
    handle&.squish!&.upcase!
  end

  def roles_rules
    self.roles = [] unless roles.is_a?(Array)
    self.roles.select! { |role| ALLOWED_ROLES.include?(role) }
    self.roles = ["member"] if roles.empty?
    self.roles.uniq!
    self.roles.sort!
    self.roles.reject! { |role| role != "admin"  } if roles.include?("admin")
    self.roles.reject! { |role| role == "member" } if roles.include?("member") && roles.length > 1
  end
end
