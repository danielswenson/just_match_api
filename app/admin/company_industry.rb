# frozen_string_literal: true

ActiveAdmin.register CompanyIndustry do
  menu parent: 'Jobs'

  permit_params do
    %i(company_id industry_id)
  end
end
