# frozen_string_literal: true

require 'rails_helper'

describe HartFormatter do

  it 'notifies admins when an error is logged' do
    # ensure we have at least one admin
    FactoryBot.create :admin
    expect do
      Rails.logger.error('My Error')
    end.to change(Notification, :count).by(User.admin.size)
  end

  it 'does not notify admins when the log is not an error' do
    # ensure at least one admin
    FactoryBot.create :admin
    expect do
      Rails.logger.info('My Info')
    end.not_to change(Notification, :count)
  end
end