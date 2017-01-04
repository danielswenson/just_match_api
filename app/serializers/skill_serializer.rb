# frozen_string_literal: true
class SkillSerializer < ApplicationSerializer
  ATTRIBUTES = [:name].freeze

  attributes ATTRIBUTES

  link(:self) { api_v1_skill_url(object) }

  has_one :language
end

# == Schema Information
#
# Table name: skills
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :integer
#  internal    :boolean          default(FALSE)
#  color       :string
#
# Indexes
#
#  index_skills_on_language_id  (language_id)
#  index_skills_on_name         (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_07eab65450  (language_id => languages.id)
#
