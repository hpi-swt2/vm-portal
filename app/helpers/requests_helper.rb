# frozen_string_literal: true

module RequestsHelper

  # replaces all whitespaces and special characters by a hyphen and makes the string to lower case
  def replace_whitespaces(name)
    name.parameterize
  end

  def mb_to_gb(megabytes)
    megabytes / 1000
  end

  def gb_to_mb(gigabytes)
    gigabytes * 1000
  end
end
