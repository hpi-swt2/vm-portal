# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VmsHelper, type: :helper do
  context 'when notifying users about changes in their rights regarding a VM' do
    before do
      users_before = FactoryBot.create_list(:employee, 4)
      @removed_users = [users_before[1], users_before[3]]
      @kept_users = [users_before[0], users_before[2]]
      @added_users = FactoryBot.create_list(:employee, 2)
      users_after = [@added_users[0], @added_users[1], users_before[0], users_before[2]]

      sudo_list = false
      vm_name = 'MyTestVm'
      notify_changed_users(users_before, users_after, sudo_list, vm_name)
    end

    it 'notifies removed users about their removal' do
      @removed_users.each do |user|
        notification = Notification.where(user: user)[0]
        expect(notification.title).to eq('User rights revoked')
      end
    end

    it 'notifies added users about their addition' do
      @added_users.each do |user|
        notification = Notification.where(user: user)[0]
        expect(notification.title).to eq('User rights granted')
      end
    end

    it 'does not notify users, whose status didn\'t change' do
      @kept_users.each do |user|
        notifications = Notification.where(user: user)
        expect(notifications).to be_empty
      end
    end
  end
end
