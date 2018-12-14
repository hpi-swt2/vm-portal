# frozen_string_literal: true

class RequestTemplate < ApplicationRecord
  validates :name, :cpu_cores, :ram_mb, :storage_mb, :operating_system, presence: true
  validates :cpu_cores, numericality: { greater_than: 0, less_than: 65 }
  validates :ram_mb, numericality: { greater_than: 0, less_than: 257_000 }
  validates :storage_mb, numericality: { greater_than: 0, less_than: 1_000_000 }
end
