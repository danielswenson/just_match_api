# frozen_string_literal: true
class Token < ApplicationRecord
  DEFAULT_EXPIRE_IN_DAYS = 14

  CATEGORY_EXPIRES_IN_HOURS = {
    login: DEFAULT_EXPIRE_IN_DAYS * 24,
    magic_login: 4,
    reset_password: 4
  }.freeze

  CATEGORIES = {
    login: 1,
    reset_password: 2,
    magic_login: 3
  }.freeze

  belongs_to :user

  before_validation :default_expires_at
  before_create :regenerate_token

  validates :user, presence: true
  validates :token, uniqueness: true
  validates :expires_at, presence: true

  scope :expires_before, ->(datetime) { where('expires_at < ?', datetime) }
  scope :expires_after, ->(datetime) { where('expires_at > ?', datetime) }
  scope :expired, -> { expires_before(Time.zone.now) }
  scope :not_expired, -> { expires_after(Time.zone.now) }
  scope :ready_for_deletion, -> { expires_before(6.months.ago) }

  enum category: CATEGORIES

  def expired?
    expires_at < Time.zone.now
  end

  def regenerate_token
    self.token = SecureGenerator.token
  end

  def default_expires_at
    self.expires_at = expires_at || begin
      CATEGORY_EXPIRES_IN_HOURS.fetch(category, DEFAULT_EXPIRE_IN_DAYS.days.from_now)
    end
  end
end

# == Schema Information
#
# Table name: tokens
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tokens_on_token    (token)
#  index_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_ac8a5d0441  (user_id => users.id)
#
