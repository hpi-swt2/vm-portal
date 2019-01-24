# frozen_string_literal: true

class RequestTemplate < ApplicationRecord
  MAX_CPU_CORES = 64
  MAX_RAM_GB = 256
  MAX_STORAGE_GB = 1_000

  validates :name, :cpu_cores, :ram_gb, :storage_gb, :operating_system, presence: true
  validates :cpu_cores, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_CPU_CORES }
  validates :ram_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_RAM_GB }
  validates :storage_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: MAX_STORAGE_GB }
end
