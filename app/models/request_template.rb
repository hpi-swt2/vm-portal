# frozen_string_literal: true

class RequestTemplate < ApplicationRecord
  validates :name, :cpu_cores, :ram_gb, :storage_gb, :operating_system, presence: true
  validates :cpu_cores, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: Request::MAX_CPU_CORES }
  validates :ram_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: Request::MAX_RAM_GB }
  validates :storage_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: Request::MAX_STORAGE_GB }
end
