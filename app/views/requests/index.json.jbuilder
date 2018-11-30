# frozen_string_literal: true

json.array! @requests, partial: 'requests/request', as: :request
