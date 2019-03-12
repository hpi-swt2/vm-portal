# frozen_string_literal: true

class RequestTemplate < ApplicationRecord
  def min_cpu_cores
    Request.min_cpu_cores
  end

  def max_cpu_cores
    Request.max_cpu_cores
  end

  def max_ram_size
    Request.max_ram_size
  end

  def max_storage_size
    Request.max_storage_size
  end

  validates :name, :cpu_cores, :ram_gb, :storage_gb, :operating_system, presence: true
  validates :cpu_cores, numericality: { only_integer: true, greater_than: :min_cpu_cores, less_than_or_equal_to: :max_cpu_cores }
  validates :ram_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: :max_ram_size }
  validates :storage_gb, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: :max_storage_size }
end
