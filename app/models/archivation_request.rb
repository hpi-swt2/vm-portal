# frozen_string_literal: true

class ArchivationRequest < ApplicationRecord
  def self.timeout
    AppSetting.instance.vm_archivation_timeout.days
  end

  def can_be_executed?
    Time.now >= created_at + timeout
  end
end
