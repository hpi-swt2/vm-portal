# frozen_string_literal: true

class AddNameToRequestTemplate < ActiveRecord::Migration[5.2]
  def change
    add_column :request_templates, :name, :string
  end
end
