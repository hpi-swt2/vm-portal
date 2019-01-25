# frozen_string_literal: true

class ArchivationRequest < ApplicationRecord
  def can_be_executed?
    three_days = 60 * 60 * 24 * 3
    Time.now >= created_at + three_days
  end
end