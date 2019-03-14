# frozen_string_literal: true

module ApplicationHelper
  ALERT_TYPES = %i[success info warning danger].freeze unless const_defined?(:ALERT_TYPES)

  def translate_flash_key(type)
    type = type.to_sym
    case type
    when :notice then :success
    when :alert then :danger
    when :error then :danger
    else
      type
    end
  end

  def viewable_for(user)
    user.admin? || Rails.env.development?
  end
end
