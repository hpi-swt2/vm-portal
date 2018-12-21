# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/show', type: :view do
  before do
    @user = FactoryBot.create(:user)
    @second_user = FactoryBot.create(:user, email: 'test@test.de')
    @request = assign(:request, Request.create!(
                                  name: 'MyVM',
                                  cpu_cores: 2,
                                  ram_mb: 1000,
                                  storage_mb: 2000,
                                  operating_system: 'MyOS',
                                  port: '4000',
                                  application_name: 'MyName',
                                  description: 'Description',
                                  comment: 'Comment',
                                  status: 'pending',
                                  user_ids: [@user.id],
                                ))
    @request.assign_sudo_users([@second_user.id])
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/MyVM/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/1000/)
    expect(rendered).to match(/2000/)
    expect(rendered).to match(/MyOS/)
    expect(rendered).to match(/4000/)
    expect(rendered).to match(/MyName/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Comment/)
    expect(rendered).to match(/pending/)
    expect(rendered).to match(@user.email)
    expect(rendered).to match(@second_user.email)
  end
end
