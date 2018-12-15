# frozen_string_literal: true

json.extract! request_template, :id, :cpu_count, :ram_mb, :storage_mb, :operating_system, :created_at, :updated_at
json.url request_template_url(request_template, format: :json)
