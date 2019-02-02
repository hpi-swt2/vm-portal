# frozen_string_literal: true

module RequestsHelper
  # replaces all whitespaces and special characters by a hyphen and makes the string to lower case
  def replace_whitespaces(name)
    name.parameterize
  end
end
