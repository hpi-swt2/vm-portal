class Request < ApplicationRecord
  enum status: %i[pending accepted rejected]
end
