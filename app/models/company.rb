# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :users
  has_many :owned_jobs, through: :users

  has_many :company_images

  has_many :company_industries
  has_many :industries, through: :company_industries

  before_validation :add_protocol_to_website
  before_validation :set_default_billing_email

  validates :name, length: { minimum: 2 }, allow_blank: false
  validates :cin, uniqueness: true, length: { is: 10 }, allow_blank: false
  validates :email, presence: true
  validates :billing_email, presence: true
  validates :street, length: { minimum: 5 }, allow_blank: false
  validates :zip, length: { minimum: 5 }, allow_blank: false
  validates :municipality, swedish_municipality: true
  validates :city, length: { minimum: 1 }, allow_blank: false
  validates :frilans_finans_id, uniqueness: true, allow_nil: true
  validates :website, url: true

  # Virtual attributes for Frilans Finans
  attr_accessor :user_frilans_finans_id, :country_name

  scope :needs_frilans_finans_id, (lambda {
    where(frilans_finans_id: nil).
      joins(:users).where('users.frilans_finans_id IS NOT NULL')
  })

  include Translatable
  translates :short_description, :description

  # NOTE: This is needed in order to be able to have it as a form input in the admin UI
  attr_reader :language

  def display_name
    "##{id} #{name}"
  end

  def anonymize
    assign_attributes(
      id: -1,
      name: 'Anonymous',
      cin: 'XYZXYZXYZX',
      email: 'anonymous@example.com',
      billing_email: 'anonymous@example.com',
      website: 'https://example.com',
      street: 'XYZXYZ XX',
      zip: 'XYZX YZ',
      city: 'XYZXYZ'
    )
    self
  end

  def address
    [street, zip, city, 'Sverige'].compact.join(', ')
  end
  alias_method :full_street_address, :address

  def country_name
    'Sweden'
  end

  def country_code
    'SE'
  end

  def guaranteed_description
    return description if description.present?
    return short_description if short_description.present?

    I18n.t(
      'arbetsformedlingen.company_description',
      name: name,
      address: address,
      url: website
    )
  end

  def company_image_logo
    company_images.last
  end

  def logo_image_token=(token)
    return if token.blank?

    company_image = CompanyImage.find_by_one_time_token(token)
    self.company_images = [company_image] unless company_image.nil?
  end

  def add_protocol_to_website
    return if website.blank?

    self.website = URLHelper.add_protocol(website.strip)
  end

  def set_default_billing_email
    return if billing_email.present?
    return if email.blank?

    self.billing_email = email
  end
end

# == Schema Information
#
# Table name: companies
#
#  id                :integer          not null, primary key
#  name              :string
#  cin               :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  frilans_finans_id :integer
#  website           :string
#  email             :string
#  street            :string
#  zip               :string
#  city              :string
#  phone             :string
#  billing_email     :string
#  municipality      :string
#
# Indexes
#
#  index_companies_on_cin                (cin) UNIQUE
#  index_companies_on_frilans_finans_id  (frilans_finans_id) UNIQUE
#
