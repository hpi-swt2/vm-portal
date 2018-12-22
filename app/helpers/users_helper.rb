# frozen_string_literal: true

module UsersHelper
  def last_admin?(user)
    user.admin? &&
      current_user?(user) &&
      only_one_admin?
  end

  def only_one_admin?
    User.all.select(&:admin?).size == 1
  end

  def current_user?(user)
    user == current_user
  end
end
