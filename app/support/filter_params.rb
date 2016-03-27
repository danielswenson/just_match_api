# frozen_string_literal: true
module FilterParams
  def self.filtered_fields(filters, allowed, transform)
    return {} if filters.nil? || filters.is_a?(String)

    filtered = {}
    filters.each do |key, value|
      key_sym = key.to_sym
      if allowed.include?(key_sym)
        filtered[key_sym] = format_value(value, transform[key_sym])
      end
    end
    filtered
  end

  def self.format_value(value, type)
    case type
    when :date_range
      format_date_range(value)
    else
      value
    end
  end

  def self.format_date_range(value)
    date_parts = value.split('..')
    start = date_parts.first.to_date
    finish = date_parts.last.to_date
    start..finish
  rescue ArgumentError, 'invalid date' => _e
    nil
  end
end