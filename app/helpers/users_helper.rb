# frozen_string_literal: true

module UsersHelper
  def last_admin?(user)
    user.admin? && only_one_admin?
  end

  def only_one_admin?
    User.all.select(&:admin?).size == 1
  end

  def current_user?(user)
    user == current_user
  end

  def editable_for(user)
    !last_admin?(user) || Rails.env.development?
  end
end
