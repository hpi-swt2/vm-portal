# frozen_string_literal: true

json.extract! operation_system, :id, :name, :created_at, :updated_at
json.url operation_system_url(operation_system, format: :json)
