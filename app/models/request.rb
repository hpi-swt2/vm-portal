# frozen_string_literal: true

class Request < ApplicationRecord
  enum status: %i[pending accepted rejected]
end
