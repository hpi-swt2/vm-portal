# frozen_string_literal: true

json.extract! server, :id, :created_at, :updated_at
json.url server_url(server, format: :json)
