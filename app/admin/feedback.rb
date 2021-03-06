# frozen_string_literal: true

ActiveAdmin.register Feedback do
  menu parent: 'Users'

  permit_params do
    %i(user_id job_id title body)
  end
end
