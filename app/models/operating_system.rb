# frozen_string_literal: true

class OperatingSystem < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
