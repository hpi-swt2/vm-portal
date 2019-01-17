# frozen_string_literal: true

module RequestsHelper
  def replace_whitespaces(name)
    name.parameterize(preserve_case: true)
  end
end
