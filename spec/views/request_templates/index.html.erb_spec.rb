# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'request_templates/index', type: :view do
  let(:request_templates) do
    FactoryBot.create_list(:request_template, 2)
  end

  let(:current_user) { FactoryBot.create :user }

  before do
    sign_in current_user
    assign(:request_templates, request_templates)
    render
  end

  it 'renders a list of request_templates in a table' do
    expect(rendered).to have_css("tbody>tr", count: request_templates.size)
  end

  it 'renders a request template names' do
    expect(rendered).to have_css("td", text: request_templates.first.name, count: request_templates.size)
  end

  context 'when the user is an user' do
    let(:current_user) { FactoryBot.create :user }

    it 'does not have a link to the request templates edit page' do
      expect(rendered).not_to have_link(href: edit_request_template_path(request_templates[0]))
      expect(rendered).not_to have_link(href: edit_request_template_path(request_templates[1]))
    end

    it 'does not have a request delete button' do
      expect(rendered).not_to have_link(id: "deleteRequestTemplateButton-#{request_templates[0].id}")
      expect(rendered).not_to have_link(id: "deleteRequestTemplateButton-#{request_templates[1].id}")
    end
  end

  context 'when the user is an employee' do
    let(:current_user) { FactoryBot.create :employee }

    it 'does not have a link to the request templates edit page' do
      expect(rendered).not_to have_link(href: edit_request_template_path(request_templates[0]))
      expect(rendered).not_to have_link(href: edit_request_template_path(request_templates[1]))
    end

    it 'does not have a request delete button' do
      expect(rendered).not_to have_link(id: "deleteRequestTemplateButton-#{request_templates[0].id}")
      expect(rendered).not_to have_link(id: "deleteRequestTemplateButton-#{request_templates[1].id}")
    end
  end

  context 'when the user is an admin' do
    let(:current_user) { FactoryBot.create :admin }

    it 'does have a link to the request templates edit page' do
      expect(rendered).to have_link(href: edit_request_template_path(request_templates[0]))
      expect(rendered).to have_link(href: edit_request_template_path(request_templates[1]))
    end

    it 'does have a request delete button' do
      expect(rendered).to have_link(id: "deleteRequestTemplateButton-#{request_templates[0].id}")
      expect(rendered).to have_link(id: "deleteRequestTemplateButton-#{request_templates[1].id}")
    end
  end
end
