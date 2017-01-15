# frozen_string_literal: true
class AddCategoryToTokens < ActiveRecord::Migration[5.0]
  def change
    add_column :tokens, :category, :integer
  end
end
