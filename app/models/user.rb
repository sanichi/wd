class User < ApplicationRecord
  has_secure_password

  MAX_NAME = 25
  MAX_ROLE = 20
  MAX_HANDLE = 4
  MIN_HANDLE = 2
  MIN_PASSWORD = 10
  ROLES = %w/member blogger librarian admin/.each do |r|
    define_method "#{r}?" do
      r == role
    end
  end

  before_validation :normalize_attributes

  validates :handle,
    format: { with: /\A[A-Z]+\z/, message: "is invalid (all caps)"},
    length: { minimum: MIN_HANDLE, maximum: MAX_HANDLE },
    uniqueness: true
  validates :name, format: { with: /\A[A-Z][a-z]+ (O'|Mc|Mac)?[A-Z][a-z]+\z/, message: "is invalid (first and last names)" }
  validates :password, length: { minimum: MIN_PASSWORD }, allow_nil: true
  validates :role, inclusion: { in: ROLES }

  scope :by_name, -> { order(:name) }

  def thing
    "#{I18n.t('user.user')} #{handle}"
  end

  private

  def normalize_attributes
    name&.squish!
    handle&.squish!&.upcase!
  end
end
