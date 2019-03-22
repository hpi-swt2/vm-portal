# frozen_string_literal: true

require 'rails_helper'

# We should add some tests here, which test that the validation is correct
RSpec.describe AppSetting, type: :model do
  describe 'validation tests' do
    let(:app_setting) {FactoryBot.build :app_setting}

    context 'when settings are invalid' do
      it 'is invalid with if it is not the first setting' do
        app_setting.singleton_guard = 2
        expect(app_setting).to be_invalid
      end
    end

    context 'when settings are valid' do
      it 'is valid with valid attributes' do
        expect(app_setting).to be_valid
      end
    end

  end
end
