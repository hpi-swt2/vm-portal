# frozen_string_literal: true

class RequestTemplate < ApplicationRecord
  validates :name, :cpu_cores, :ram_mb, :storage_mb, :operating_system, presence: true
  validates :cpu_cores, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: Request::MAX_CPU_CORES }
  validates :ram_mb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: Request::MAX_RAM_MB }
  validates :storage_mb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: Request::MAX_STORAGE_MB }
end
