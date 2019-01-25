# frozen_string_literal: true

module RequestsHelper
  def replace_whitespaces(name)
    name.parameterize(preserve_case: true)
  end

  def mb_to_gb(megabytes)
    megabytes / 1000
  end

  def gb_to_mb(gigabytes)
    gigabytes * 1000
  end
end
