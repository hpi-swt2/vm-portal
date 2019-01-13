# frozen_string_literal: true

class AddRequestAuthorToRequest < ActiveRecord::Migration[5.2]
  def change
    add_reference :requests, :user, index: true, foreign_key: true
    update_requests
  end

  def update_requests
    employee = User.find_by_email('employee@employee.de')
    Request.all.each do |request|
      request.user = employee
      request.save
    end
  end
end
