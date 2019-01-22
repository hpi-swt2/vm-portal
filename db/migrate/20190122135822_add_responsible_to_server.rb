class AddResponsibleToServer < ActiveRecord::Migration[5.2]
  def change
    add_column :servers, :responsible, :string
  end
end
