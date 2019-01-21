# frozen_string_literal: true

class ArchivationRequest < ApplicationRecord
  def can_be_executed?
    created_at + (60 * 60 * 24 * 3) >= Time.now
  end
end