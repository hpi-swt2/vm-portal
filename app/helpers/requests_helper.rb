# frozen_string_literal: true

module RequestsHelper
  def request_accept(request)
    request.status = 'accepted'
    request.save
  end

  def request_reject(request)
    request.status = 'rejected'
    request.save
  end
end
