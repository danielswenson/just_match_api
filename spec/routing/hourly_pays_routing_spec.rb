# frozen_string_literal: true
# == Schema Information
#
# Table name: hourly_pays
#
#  id         :integer          not null, primary key
#  active     :boolean          default(FALSE)
#  rate       :integer
#  currency   :string           default("SEK")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Api::V1::HourlyPaysController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      path = '/api/v1/hourly-pays/'
      route_path = 'api/v1/hourly_pays#index'
      expect(get: path).to route_to(route_path)
    end
  end
end