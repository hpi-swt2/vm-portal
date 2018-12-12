# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/show', type: :view do
  before do
    @request = assign(:request, Request.create!(
                                  name: 'MyVM',
                                  cpu_cores: 2,
                                  ram_mb: 1000,
                                  storage_mb: 2000,
                                  operating_system: 'MyOS',
                                  port: '4000',
                                  reachability_name: 'MyName',
                                  comment: 'Comment',
                                  status: 'pending'
                                ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/MyVM/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/1000/)
    expect(rendered).to match(/2000/)
    expect(rendered).to match(/4000/)
    expect(rendered).to match(/MyName/)
    expect(rendered).to match(/Comment/)
    expect(rendered).to match(/pending/)
  end
end
