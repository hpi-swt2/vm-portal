require 'rails_helper'

RSpec.describe 'requests/show', type: :feature do
  context 'pending request' do
    before(:each) do
      @request=FactoryBot.create :request
    end

    it 'renders attributes in <p>' do
      visit request_path(@request)

      expect(page).to have_text(@request.operating_system)
      expect(page).to have_text(@request.ram_mb)
      expect(page).to have_text(@request.cpu_cores)
      expect(page).to have_text(@request.software)
      expect(page).to have_text(@request.status)
    end

    it 'has accept button' do
      visit request_path(@request)

      click_button('Accept')
      @request.reload
      expect(@request.status).to eq('accepted')
    end

    it 'has reject button' do
      visit request_path(@request)

      click_button('Reject')
      @request.reload
      expect(@request.status).to eq('rejected')
    end

    it 'has comment input field' do
      visit request_path(@request)

      page.fill_in 'request[comment]', with: 'Comment'
      click_button('Reject')
      @request.reload
      expect(@request.comment).to eq('Comment')
    end
  end

  context 'rejected request' do
    before(:each) do
      @request=FactoryBot.create :rejected_request
    end

    it 'Has comment field' do
      visit request_path(@request)
      
      expect(page).to have_text(@request.comment)
    end
  end

end
