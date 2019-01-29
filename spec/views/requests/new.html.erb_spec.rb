# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/new', type: :view do
  before do
    @user = FactoryBot.create(:user)
    assign(:request, Request.new(
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
                       user: FactoryBot.create(:employee)
                     ))
    assign(:request_templates, [RequestTemplate.new(
      name: 'MyTemplate',
      cpu_cores: 2,
      ram_gb: 1,
      storage_gb: 2,
      operating_system: 'CentOS 7'
    )])
    render
  end

  context 'when a template should be selected' do
    it 'has a list of templates' do
      expect(rendered).to have_text('Request templates')
      expect(rendered).to have_css('.template')
    end

    it 'has a list with \"none\" template' do
      expect(rendered).to have_css('.template')
      expect(rendered).to have_text('None')
    end

    context 'when a new template is generated' do
      it 'has a list with this pre-generated template' do
        expect(rendered).to have_css('.template')
        expect(rendered).to have_text('MyTemplate: 2 CPU cores, 1 GB RAM, 2 GB Storage, CentOS 7')
      end
    end
  end

  it 'renders new request form' do
    assert_select 'form[action=?][method=?]', requests_path, 'post' do
      assert_select 'input[name=?]', 'request[name]'

      assert_select 'input[name=?][min=?]', 'request[cpu_cores]', '0'

      assert_select 'input[name=?][min=?]', 'request[ram_mb]', '0'

      assert_select 'input[name=?][min=?]', 'request[storage_mb]', '0'

      assert_select 'select[name=?]', 'request[operating_system]'

      assert_select 'input[name=?][min=?]', 'request[port]', '0'

      assert_select 'input[name=?]', 'request[application_name]'

      assert_select 'textarea[name=?]', 'request[description]'

      assert_select 'textarea[name=?]', 'request[comment]'
    end

    expect(rendered).to match(@user.email)
  end
end
