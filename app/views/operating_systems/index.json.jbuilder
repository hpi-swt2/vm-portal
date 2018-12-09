# frozen_string_literal: true

json.array! @operating_systems, partial: 'operating_systems/operating_system', as: :operating_system
