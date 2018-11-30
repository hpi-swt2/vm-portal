# frozen_string_literal: true

json.extract! request, :id, :name, :cpu_cores, :ram_mb, :storage_mb, :operating_system, :software, :comment, :rejection_information, :status, :created_at, :updated_at
json.url request_url(request, format: :json)
