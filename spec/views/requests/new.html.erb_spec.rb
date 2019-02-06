# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'requests/new', type: :view do
  let(:user) { FactoryBot.create :user }

  let(:request) do
#    FactoryBot.build(:request, user: FactoryBot.create(:employee))

    Request.new(
      name: 'myvm',
      cpu_cores: 2,
      ram_gb: 1,
      storage_gb: 2,
      operating_system: 'MyOS',
      port: '4000',
      application_name: 'MyName',
      description: 'Description',
      comment: 'Comment',
      status: 'pending',
      user: FactoryBot.create(:employee),
      project: FactoryBot.create(:project)
    )

  end

  before do
    assign(:user, user)
    assign(:request, request)
    assign(:request_templates, [FactoryBot.build(:request_template)])
    render
  end

  context 'when a template should be selected' do
    it 'has a dropdown for selecting templates' do
      expect(rendered).to have_select 'request_template_id'
    end

    it 'has a dropdown labelled \"Template\"' do
      expect(rendered).to have_text('Template')
    end

    it 'has a select with \"none\" template as option' do
      expect(rendered).to have_select 'request_template_id', with_options: ['None']
    end

    context 'when a new template is generated' do
      it 'has a list with this pre-generated template' do
        expect(rendered).to have_select 'request_template_id', with_options: ['My Template: 1 CPU cores, 1 GB RAM, 1 GB Storage, MyString']
      end
    end
  end

  it 'renders new request form' do
    assert_select 'form[action=?][method=?]', requests_path, 'post' do
      assert_select 'input[name=?]', 'request[name]'

      assert_select 'input[name=?][min=?]', 'request[cpu_cores]', '0'

      assert_select 'input[name=?][min=?]', 'request[ram_gb]', '0'

      assert_select 'input[name=?][min=?]', 'request[storage_gb]', '0'

      assert_select 'select[name=?]', 'request[operating_system]'

      assert_select 'input[name=?][min=?]', 'request[port]', '0'

      assert_select 'input[name=?]', 'request[application_name]'

      assert_select 'textarea[name=?]', 'request[description]'

      assert_select 'textarea[name=?]', 'request[comment]'
    end

    expect(rendered).to match(user.email)
  end

  # regression test for #320
  context 'when request is not persisted' do
    it 'is not persisted' do
      expect(request).not_to be_persisted
    end

    it 'renders ram_gb' do
      assert_select 'input[id=ram][value=?]', request.ram_gb.to_s
    end

    it 'renders storage_gb' do
      assert_select 'input[id=storage][value=?]', request.storage_gb.to_s
    end
  end
end
