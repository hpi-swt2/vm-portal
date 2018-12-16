# frozen_string_literal: true

json.array! @request_templates, partial: 'request_templates/request_template', as: :request_template
