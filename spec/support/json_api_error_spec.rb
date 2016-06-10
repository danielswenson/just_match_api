# frozen_string_literal: true
require 'rails_helper'

RSpec.describe JsonApiError do
  let(:pointer) { :name }

  subject do
    json = JsonApiError.new(status: 422, detail: 'too short', pointer: pointer).to_json
    JSON.parse(json)
  end

  it 'returns correct status' do
    expect(subject['status']).to eq(422)
  end

  it 'returns correct detail' do
    expect(subject['detail']).to eq('too short')
  end

  it 'returns correct pointer' do
    expected_pointer = { 'pointer' => '/data/attributes/name' }
    expect(subject['source']).to eq(expected_pointer)
  end

  context 'with pointer' do
    let(:pointer) { nil }

    it 'returns a response without source-key' do
      expect(subject['source']).to be_nil
    end
  end
end
