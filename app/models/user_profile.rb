# frozen_string_literal: true

class UserProfile < ActiveRecord::Base
  # Associations
  belongs_to :user, optional: true

  def name
    "#{first_name} #{last_name}"
  end
end
