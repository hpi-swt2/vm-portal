# frozen_string_literal: true

class RequestTemplate < ApplicationRecord
  validates :name, :cpu_cores, :ram_gb, :storage_gb, :operating_system, presence: true
  validates_with VmValidator
end
