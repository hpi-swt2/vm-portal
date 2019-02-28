# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  queue_as :send_notification

  def perform(admins_ids, vm_name, vm_url)
    admins = User.where(id: admins_ids)
    admins.each do |admin|
      admin.notify("VM #{vm_name} has been requested to be archived", 'The VM has been shut down and has to be archived.', vm_url)
    end
  end
end
