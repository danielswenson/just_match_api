# frozen_string_literal: true
module Index
  class BaseIndex
    delegate :params, to: :controller
    delegate :policy_scope, to: :controller
    delegate :include_params, to: :controller

    DEFAULT_SORTING = { created_at: :desc }.freeze
    SORTABLE_FIELDS = %i(created_at).freeze
    PER_PAGE = Kaminari.config.default_per_page
    MAX_PER_PAGE = Kaminari.config.max_per_page
    ALLOWED_INCLUDES = [].freeze
    TRANSFORMABLE_FILTERS = { created_at: :date_range }.freeze
    ALLOWED_FILTERS = %i(created_at).freeze

    attr_reader :controller

    def initialize(controller)
      @controller = controller
    end

    def prepare_records(records)
      records = policy_scope(records).
                order(sort_params).
                page(current_page).per(current_size)

      filter_records(records)
    end

    def included
      @included ||= include_params.permit(self.class::ALLOWED_INCLUDES)
    end

    protected

    def included?(resource_name)
      included.include?(resource_name)
    end

    def user_include_scopes(user_key = :user)
      if included?(user_key.to_s)
        { user_key => %i(language languages company) }
      else
        user_key
      end
    end

    def current_size
      page_size = SafeDig.dig(params.to_unsafe_h, 'page', 'size')
      per_page = (page_size || PER_PAGE).to_i
      [per_page, self.class::MAX_PER_PAGE].min
    end

    def current_page
      page_number = SafeDig.dig(params.to_unsafe_h, 'page', 'number')
      (page_number || 1).to_i
    end

    def filter_records(records)
      filter_params.each do |field_name, value|
        records = records.where(field_name => value)
      end
      records
    end

    def sort_params
      sortable_fields = self.class::SORTABLE_FIELDS
      default_sorting = self.class::DEFAULT_SORTING
      SortParams.sorted_fields(params[:sort], sortable_fields, default_sorting)
    end

    def filter_params
      filterable_fields = self.class::ALLOWED_FILTERS
      transformable = self.class::TRANSFORMABLE_FILTERS
      FilterParams.filtered_fields(params[:filter], filterable_fields, transformable)
    end
  end
end