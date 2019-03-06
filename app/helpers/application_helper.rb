# frozen_string_literal: true

module ApplicationHelper
  ALERT_TYPES = %i[success info warning danger].freeze unless const_defined?(:ALERT_TYPES)

  def translate_flash_key(type)
    type = type.to_sym
    type = :success if type == :notice
    type = :danger  if type == :alert
    type = :danger  if type == :error
    type
  end

  def viewable_for(user)
    user.admin? || Rails.env.development?
  end
end
