# frozen_string_literal: true

module RequestsHelper
  def accept(request)
    request.status = 'accepted'
    request.save
    redirect_to new_vm_path(request: request)
  end

  def current_request
    @current_request
  end
end
