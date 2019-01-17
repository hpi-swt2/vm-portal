# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'request_templates/show', type: :view do
  let(:current_user) { FactoryBot.create :user }

  before do
    sign_in current_user

    @request_template = assign(:request_template, RequestTemplate.create!(
                                                    name: 'string',
                                                    cpu_cores: 2,
                                                    ram_mb: 3,
                                                    storage_mb: 4,
                                                    operating_system: 'Operating System'
                                                  ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/string/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/Operating System/)
  end
end
