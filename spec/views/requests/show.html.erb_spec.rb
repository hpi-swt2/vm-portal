# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/show', type: :view do
  let(:current_user) { FactoryBot.create :employee }

  before do
    @user = FactoryBot.create(:user)
    @second_user = FactoryBot.create(:user, email: 'test@test.de')
    @request = assign(:request, Request.create!(
                                  name: 'MyVM',
                                  cpu_cores: 3,
                                  ram_mb: 1000,
                                  storage_mb: 2000,
                                  operating_system: 'MyOS',
                                  port: '4000',
                                  application_name: 'MyName',
                                  description: 'Description',
                                  comment: 'Comment',
                                  status: 'pending',
                                  user_ids: [@user.id],
                                  user: FactoryBot.create(:employee)
                                ))
    @request.assign_sudo_users([@second_user.id])
    allow(view).to receive(:current_user).and_return(current_user)
    render
  end

  it 'renders attributes in <p>' do
    expect(rendered).to match(/MyVM/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyOS/)
    expect(rendered).to match(/4000/)
    expect(rendered).to match(/MyName/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Comment/)
    expect(rendered).to match(/pending/)
    expect(rendered).to match(@user.email)
    expect(rendered).to match(@second_user.email)
  end

  context 'when the current user is an employee' do
    let(:current_user) { FactoryBot.create :employee }

    it 'does not show the accept part of the page' do
      expect(rendered).not_to have_selector 'div#acceptAndReject'
    end
  end

  context 'when the current user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    # this has been moved to the edit action
    it 'does not show the accept and reject part' do
      expect(rendered).not_to have_selector 'div#acceptAndReject'
    end
  end
end
