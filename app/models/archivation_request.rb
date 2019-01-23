# frozen_string_literal: true

class ArchivationRequest < ApplicationRecord
  def can_be_executed?
    Time.now >= created_at + (60 * 60 * 24 * 3)
  end
end