# frozen_string_literal: true

json.extract! request_template, :id, :cpu_count, :ram_gb, :storage_mgb, :operating_system, :created_at, :updated_at
json.url request_template_url(request_template, format: :json)
