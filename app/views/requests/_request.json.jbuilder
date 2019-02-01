# frozen_string_literal: true

json.extract! request, :id, :name, :cpu_cores, :ram_gb, :storage_gb, :operating_system, :comment, :rejection_information, :status, :created_at, :updated_at
json.url request_url(request, format: :json)
