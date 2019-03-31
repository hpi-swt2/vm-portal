# frozen_string_literal: true

class RequestTemplate < ApplicationRecord
  validates :name, :cpu_cores, :ram_gb, :storage_gb, :operating_system, presence: true
  validates_with VmValidator

  # String of the most relevant attributes. Used for display in form select
  def text_summary
    "#{name}: #{cpu_cores} CPU Cores, #{ram_gb} GB RAM, #{storage_gb} GB Storage, #{operating_system}"
  end
end

