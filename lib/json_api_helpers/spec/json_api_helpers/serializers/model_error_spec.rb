
# frozen_string_literal: true
require 'spec_helper'
require 'active_model'

RSpec.describe JsonApiHelpers::Serializers::ModelError do
  class ExampleModel
    include ActiveModel::Model

    attr_accessor :name
    validates :name, length: { minimum: 3 }, presence: true
  end

  let(:model) { ExampleModel.new.tap(&:validate) }
  let(:errors) { described_class.serialize(model) }
  let(:min_error) { errors.first }
  let(:blank_error) { errors.last }

  it 'returns an array' do
    expect(errors).to be_an(Array)
  end

  it 'returns 422 unprocessable entity status' do
    expect(min_error[:status]).to eq(422)
  end

  it 'returns source key' do
    expect(min_error[:source]).to be_a(Hash)
  end

  it 'returns the correct pointer under source key' do
    expect(min_error.dig(:source, :pointer)).to eq('/data/attributes/name')
  end

  it 'returns an array' do
    expect(min_error[:detail]).to eq('is too short (minimum is 3 characters)')
  end

  it 'returns correct meta hash for too short error' do
    expect(min_error[:meta]).to eq(type: :too_short, count: 3)
  end

  it 'returns correct meta hash for presence error' do
    expect(blank_error[:meta]).to eq(type: :blank)
  end
end
