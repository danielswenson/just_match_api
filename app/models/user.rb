
# frozen_string_literal: true
class User < ApplicationRecord
  include Geocodable
  include SkillMatchable

  MIN_PASSWORD_LENGTH = 6
  MAX_PASSWORD_LENGTH = 50
  ONE_TIME_TOKEN_VALID_FOR_HOURS = 18

  LOCATE_BY = {
    address: { lat: :latitude, long: :longitude }
  }.freeze

  STATUSES = {
    asylum_seeker: 1,
    permanent_residence: 2,
    temporary_residence_work: 3,
    student_visa: 4
  }.freeze

  AT_UND = {
    yes: 1,
    no: 2
  }.freeze

  attr_accessor :password

  after_validation :set_normalized_phone, :set_normalized_ssn, :set_normalized_email, :set_normalized_bank_account # rubocop:disable Metrics/LineLength

  before_save :encrypt_password

  belongs_to :language
  belongs_to :company, optional: true

  has_many :user_tags
  has_many :tags, through: :user_tags

  has_many :auth_tokens, class_name: 'Token', dependent: :destroy

  has_many :user_skills
  has_many :skills, through: :user_skills

  has_many :owned_jobs, class_name: 'Job', foreign_key: 'owner_user_id'

  has_many :job_users
  has_many :jobs, through: :job_users

  has_many :user_languages, dependent: :destroy
  has_many :languages, through: :user_languages

  has_many :written_comments, class_name: 'Comment', foreign_key: 'owner_user_id'

  has_many :chat_users
  has_many :chats, through: :chat_users

  has_many :messages, class_name: 'Message', foreign_key: 'author_id'

  has_many :user_images

  has_many :given_ratings, class_name: 'Rating', foreign_key: 'from_user_id'
  has_many :received_ratings, class_name: 'Rating', foreign_key: 'to_user_id'

  validates :language, presence: true
  validates :email, presence: true, uniqueness: true
  validates :first_name, length: { minimum: 2 }, allow_blank: false
  validates :last_name, length: { minimum: 2 }, allow_blank: false
  validates :phone, length: { minimum: 9 }, uniqueness: true, allow_blank: false
  validates :street, length: { minimum: 5 }, allow_blank: true
  validates :zip, length: { minimum: 5 }, allow_blank: true
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }, allow_blank: false, on: :create # rubocop:disable Metrics/LineLength
  validates :ssn, uniqueness: true, allow_blank: true
  validates :frilans_finans_id, uniqueness: true, allow_nil: true
  validates :country_of_origin, inclusion: { in: ISO3166::Country.translations.keys }, allow_blank: true # rubocop:disable Metrics/LineLength

  validate :validate_arrived_at_date
  validate :validate_language_id_in_available_locale
  validate :validate_format_of_phone_number
  validate :validate_swedish_phone_number
  validate :validate_swedish_ssn
  validate :validate_swedish_bank_account
  validate :validate_arrival_date_in_past

  scope :admins, -> { where(admin: true) }
  scope :company_users, -> { where.not(company: nil) }
  scope :regular_users, -> { where(company: nil) }
  scope :managed_users, -> { where(managed: true) }
  scope :visible, -> { where.not(banned: true) }
  scope :valid_one_time_tokens, lambda {
    where('one_time_token_expires_at > ?', Time.zone.now)
  }
  scope :frilans_finans_users, -> { where.not(frilans_finans_id: nil) }
  scope :needs_frilans_finans_id, lambda {
    not_anonymized.regular_users.where(frilans_finans_id: nil)
  }
  scope :anonymized, -> { where(anonymized: true) }
  scope :not_anonymized, -> { where(anonymized: false) }
  scope :verified, -> { where(verified: true) }

  # NOTE: Figure out a good way to validate :current_status and :at_und
  #       see https://github.com/rails/rails/issues/13971
  enum current_status: STATUSES
  enum at_und: AT_UND

  include Translatable
  translates :description, :job_experience, :education, :competence_text

  # NOTE: This is necessary for nested activeadmin has_many form
  accepts_nested_attributes_for :user_skills, :user_languages
  accepts_nested_attributes_for :user_tags, allow_destroy: true

  # Don't change the order or remove any items in the array,
  # only additions are allowed
  NOTIFICATIONS = %w(
    accepted_applicant_confirmation_overdue
    accepted_applicant_withdrawn
    applicant_accepted
    applicant_will_perform
    invoice_created
    job_user_performed
    job_cancelled
    new_applicant
    user_job_match
    new_chat_message
    new_job_comment
  ).freeze

  def self.ransackable_scopes(_auth_object = nil)
    [:by_near_address]
  end

  def self.find_by_one_time_token(category, token)
    auth_tokens.not_expired.find_by(category: category, token: token)&.user
  end

  def self.find_by_credentials(email_or_phone:, password:)
    user = find_by_email_or_phone(email_or_phone)

    return if user.nil?
    return unless correct_password?(user, password)

    user
  end

  def self.find_token(auth_token)
    Token.not_expired.find_by(token: auth_token)
  end

  def self.find_by_auth_token(auth_token)
    find_token(auth_token)&.user
  end

  def self.find_by_phone(phone, normalize: false)
    phone_number = phone
    if normalize
      phone_number = PhoneNumber.normalize(phone_number)
      return if phone_number.nil? # The phone number format is invalid
    end

    find_by(phone: phone_number)
  end

  def self.find_by_email_or_phone(email_or_phone)
    return if email_or_phone.blank?

    email = email_or_phone.downcase
    phone = email_or_phone
    find_by(email: email) || find_by_phone(phone, normalize: true)
  end

  def self.correct_password?(user, password)
    password_hash = BCrypt::Engine.hash_secret(password, user.password_salt)
    user.password_hash.eql?(password_hash)
  end

  def self.wrong_password?(user, password)
    !correct_password?(user, password)
  end

  def self.matches_job(job, distance: 20, strict_match: false)
    lat = job.latitude
    long = job.longitude

    within(lat: lat, long: long, distance: distance).
      order_by_matching_skills(job, strict_match: strict_match)
  end

  def self.accepted_applicant_for_owner?(owner:, user:)
    jobs = owner.owned_jobs & JobUser.accepted_jobs_for(user)
    jobs.any?
  end

  def bank_account_details?
    return false if account_clearing_number.blank?
    return false if account_number.blank?

    true
  end

  def contact_email
    return email unless managed

    ManagedEmailAddress.call(email: email, id: "user#{id}")
  end

  def anonymize
    assign_attributes(
      id: -1,
      anonymized: true,
      first_name: 'Anonymous',
      last_name: 'User',
      email: 'anonymous@example.com',
      description: 'This user is anonymous.',
      street: 'XYZXYZ XX',
      zip: 'XYZX YZ',
      ssn: 'XYZXYZXYZX',
      company: candidate? ? nil : company.anonymize
    )
    self
  end

  def average_score
    received_ratings.average(:score)
  end

  delegate :count, to: :received_ratings, prefix: true

  # ActiveAdmin display name
  def display_name
    "##{id} #{name}"
  end

  def not_persisted?
    !persisted?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def admin?
    admin
  end

  def company?
    company_id.present?
  end

  def candidate?
    primary_role == :candidate
  end

  def locale
    return I18n.default_locale.to_s if language.nil?

    language.lang_code
  end

  def frilans_finans_id!
    frilans_finans_id || fail("User ##{id} has no Frilans Finans id!")
  end

  def primary_role
    if admin?
      :admin
    elsif company_id
      :company
    else
      :candidate
    end
  end

  def auth_token
    auth_tokens.not_expired.login.last&.token
  end

  def magic_login_token
    auth_tokens.not_expired.magic_login.first
  end

  def set_normalized_phone
    self.phone = PhoneNumber.normalize(phone)
  end

  def set_normalized_ssn
    self.ssn = SwedishSSN.normalize(ssn)
  end

  def set_normalized_email
    self.email = EmailAddress.normalize(email)
  end

  def set_normalized_bank_account
    full_account = [account_clearing_number, account_number].join
    account = SwedishBankAccount.new(full_account)
    return unless account.valid?

    self.account_clearing_number = account.clearing_number
    self.account_number = account.serial_number
  end

  # NOTE: This method has unintuitive side effects.. if the banned attribute is
  #   just set to true all associated auth_tokens will immediately be destroyed
  #   We should probably convert this to #banned! which also saves the user
  def banned=(value)
    auth_tokens.destroy_all if value
    self[:banned] = value
  end

  def profile_image_token=(token)
    ActiveSupport::Deprecation.warn('User#profile_image_token= has been deprecated, please use User#set_images_by_tokens or User#add_image_by_token instead.') # rubocop:disable Metrics/LineLength
    return if token.blank?

    user_image = UserImage.find_by_one_time_token(token)
    self.user_images = [user_image] unless user_image.nil?
  end

  def add_image_by_token=(token)
    return if token.blank?

    user_image = UserImage.find_by_one_time_token(token)
    user_images << user_image if user_image
  end

  def set_images_by_tokens=(tokens)
    return if tokens.blank?

    self.user_images = UserImage.find_by_one_time_tokens(tokens)
  end

  def ignored_notification?(notification)
    ignored_notifications.include?(notification.to_s)
  end

  def ignored_notifications=(notifications)
    self.ignored_notifications_mask = BitmaskField.to_mask(notifications, NOTIFICATIONS)
  end

  def ignored_notifications
    BitmaskField.from_mask(ignored_notifications_mask, NOTIFICATIONS)
  end

  def anonymize_attributes
    assign_attributes(
      anonymized: true,
      first_name: 'Ghost',
      last_name: 'user',
      email: "ghost+#{SecureGenerator.token(length: 64)}@example.com",
      phone: nil,
      description: 'This user has been deleted.',
      street: 'Stockholm',
      zip: '11120',
      ssn: '0000000000',
      password: SecureGenerator.token
    )
  end

  def reset!
    # Update the users attributes and don't validate
    anonymize_attributes
    save!(validate: false)
  end

  def create_auth_token
    token = Token.new(category: :login)
    auth_tokens << token
    token
  end

  def generate_one_time_token(category, valid_duration: ONE_TIME_TOKEN_VALID_FOR_HOURS.hours) # rubocop:disable Metrics/LineLength
    token = Token.find_or_initialize_by(category: category, user: self)
    token.expires_at = Time.zone.now + valid_duration
    token.save!
    token
  end

  def self.valid_password_format?(password)
    return false if password.blank?
    return false unless password.is_a?(String)

    # BCrypt implementations will allow for at least 50 chars, but after that its not
    # guaranteed, see https://security.stackexchange.com/questions/39849/does-bcrypt-have-a-maximum-password-length
    password.length >= MIN_PASSWORD_LENGTH && password.length <= MAX_PASSWORD_LENGTH
  end

  def country_name
    'Sweden'
  end

  def validate_arrival_date_in_past
    return if arrived_at.nil? || arrived_at <= Time.zone.today

    error_message = I18n.t('errors.user.arrived_at_must_be_in_past')
    errors.add(:arrived_at, error_message)
  end

  def validate_language_id_in_available_locale
    language = Language.find_by(id: language_id)
    return if language.nil?

    unless I18n.available_locales.map(&:to_s).include?(language.lang_code)
      errors.add(:language_id, I18n.t('errors.user.must_be_available_locale'))
    end
  end

  def validate_format_of_phone_number
    return if PhoneNumber.valid?(phone)

    error_message = I18n.t('errors.user.must_be_valid_phone_number_format')
    errors.add(:phone, error_message)
  end

  def validate_swedish_phone_number
    return if PhoneNumber.swedish_number?(phone)

    error_message = I18n.t('errors.user.must_be_swedish_phone_number')
    errors.add(:phone, error_message)
  end

  def validate_swedish_ssn
    return unless Rails.configuration.x.validate_swedish_ssn
    return if ssn.blank?
    return if SwedishSSN.valid?(ssn)

    error_message = I18n.t('errors.user.must_be_swedish_ssn')
    errors.add(:ssn, error_message)
  end

  def validate_swedish_bank_account
    return if account_clearing_number.blank?
    return if account_number.blank?

    full_account = [account_clearing_number, account_number].join
    field_map = {
      clearing_number: :account_clearing_number,
      serial_number: :account_number,
      account: :account
    }
    SwedishBankAccount.new(full_account).tap do |account|
      account.errors_by_field do |field, error_types|
        error_types.each do |type|
          message = I18n.t("errors.bank_account.#{type}")
          errors.add(field_map[field], message)
        end
      end
    end
  end

  def validate_arrived_at_date
    arrived_at_before_cast = read_attribute_before_type_cast(:arrived_at)
    return if arrived_at_before_cast.nil?
    return unless arrived_at.nil?

    error_message = I18n.t('errors.general.must_be_valid_date')
    errors.add(:arrived_at, error_message)
  end

  private

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                               :integer          not null, primary key
#  email                            :string
#  phone                            :string
#  description                      :text
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  latitude                         :float
#  longitude                        :float
#  language_id                      :integer
#  anonymized                       :boolean          default(FALSE)
#  password_hash                    :string
#  password_salt                    :string
#  admin                            :boolean          default(FALSE)
#  street                           :string
#  zip                              :string
#  zip_latitude                     :float
#  zip_longitude                    :float
#  first_name                       :string
#  last_name                        :string
#  ssn                              :string
#  company_id                       :integer
#  banned                           :boolean          default(FALSE)
#  job_experience                   :text
#  education                        :text
#  one_time_token                   :string
#  one_time_token_expires_at        :datetime
#  ignored_notifications_mask       :integer
#  frilans_finans_id                :integer
#  frilans_finans_payment_details   :boolean          default(FALSE)
#  competence_text                  :text
#  current_status                   :integer
#  at_und                           :integer
#  arrived_at                       :date
#  country_of_origin                :string
#  managed                          :boolean          default(FALSE)
#  account_clearing_number          :string
#  account_number                   :string
#  verified                         :boolean          default(FALSE)
#  skype_username                   :string
#  interview_comment                :text
#  next_of_kin_name                 :string
#  next_of_kin_phone                :string
#  arbetsformedlingen_registered_at :date
#
# Indexes
#
#  index_users_on_company_id         (company_id)
#  index_users_on_email              (email) UNIQUE
#  index_users_on_frilans_finans_id  (frilans_finans_id) UNIQUE
#  index_users_on_language_id        (language_id)
#  index_users_on_one_time_token     (one_time_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_45f4f12508  (language_id => languages.id)
#  fk_rails_7682a3bdfe  (company_id => companies.id)
#
