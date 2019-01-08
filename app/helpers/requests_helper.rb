# frozen_string_literal: true

module RequestsHelper
	def object_as_js_var(var_name, object, content_name = nil)
        output_tag = javascript_tag("var #{var_name} = #{object.to_json};".html_safe, type: 'text/javascript')
        if content_name
            content_for content_name, output_tag
        else
            output_tag
        end
    end
end
