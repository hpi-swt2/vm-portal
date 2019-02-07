# frozen_string_literal: true

class AddProjectToVirtualMachineConfig < ActiveRecord::Migration[5.2]
  def change
    add_reference :virtual_machine_configs, :project, foreign_key: true
  end
end
