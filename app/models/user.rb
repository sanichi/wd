class User < ApplicationRecord
  has_secure_password

  MAX_NAME = 20
  MAX_HANDLE = 4
  MAX_ROLE = 20
  MIN_HANDLE = 2
  MIN_PASSWORD = 10
  ROLES = %w/guest member blogger librarian admin/.each do |r|
    define_method "#{r}?" do
      r == role
    end
  end
  ALLOWED_ROLES = ROLES.reject { |r| r == "guest" }

  has_many :blogs, dependent: :nullify, inverse_of: :user

  before_validation :normalize_attributes

  validates :handle,
    format: { with: /\A[A-Z]+\z/, message: "is invalid (all caps)"},
    length: { minimum: MIN_HANDLE, maximum: MAX_HANDLE },
    uniqueness: true
  validates :first_name, format: { with: /\A[A-Z][a-z]+\z/ }
  validates :last_name, format: { with: /\A(O'|Mac|Mc)?[A-Z][a-z]+\z/ }
  validates :password, length: { minimum: MIN_PASSWORD }, allow_nil: true
  validates :role, inclusion: { in: ALLOWED_ROLES }

  scope :by_name, -> { order(:first_name, :last_name) }

  def name
    "#{first_name} #{last_name}"
  end

  def thing
    "#{I18n.t('user.user')} #{handle}"
  end

  # for rspec tests
  def to_s
    "user"
  end

  private

  def normalize_attributes
    first_name&.squish!
    last_name&.squish!
    handle&.squish!&.upcase!
  end
end
