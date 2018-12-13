# frozen_string_literal: true

json.extract! operating_system, :id, :name, :created_at, :updated_at
json.url operating_system_url(operating_system, format: :json)
