# frozen_string_literal: true

class ArchivationRequest < ApplicationRecord
  def self.timeout
    AppSetting.instance.vm_archivation_timeout.days
  end

  def self.timeout_readable
    AppSetting.instance.vm_archivation_timeout.to_s + ' days'
  end

  def can_be_executed?
    Time.now >= created_at + self.class.timeout
  end
end
