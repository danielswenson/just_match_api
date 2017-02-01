# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DocumentSerializer, type: :serializer do
  context 'Individual Resource Representation' do
    let(:resource) { FactoryGirl.build(:document) }
    let(:serialization) { JsonApiSerializer.serialize(resource) }

    subject do
      JSON.parse(serialization.to_json)
    end

    it 'has document-url' do
      value = resource.document.url
      expect(subject).to have_jsonapi_attribute('document-url', value)
    end

    described_class::ATTRIBUTES.each do |attribute|
      it "has #{attribute.to_s.humanize.downcase}" do
        dashed_attribute = attribute.to_s.dasherize
        value = resource.public_send(attribute)
        expect(subject).to have_jsonapi_attribute(dashed_attribute, value)
      end
    end

    it 'is valid jsonapi format' do
      expect(subject).to be_jsonapi_formatted('documents')
    end
  end
end

# == Schema Information
#
# Table name: documents
#
#  id                        :integer          not null, primary key
#  one_time_token            :string
#  one_time_token_expires_at :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  document_file_name        :string
#  document_content_type     :string
#  document_file_size        :integer
#  document_updated_at       :datetime
#