# frozen_string_literal: true

module DashboardHelper
  def max_shown_vms
    AppSetting.instance.max_shown_vms
  end
end
