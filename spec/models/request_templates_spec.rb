# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestTemplate, type: :model do
  describe 'validation tests' do
    let(:request_template) { FactoryBot.build :request_template }

    context 'when request template is invalid' do
      it 'is invalid with no name' do
        request_template.name = ''
        expect(request_template).to be_invalid
      end

      it 'is invalid with no cpu_cores specifiation' do
        request_template.cpu_cores = nil
        expect(request_template).to be_invalid
      end

      it 'is invalid with no ram specifiation' do
        request_template.ram_gb = nil
        expect(request_template).to be_invalid
      end

      it 'is invalid with no storage specifiation' do
        request_template.storage_gb = nil
        expect(request_template).to be_invalid
      end

      it 'is invalid with no operating_system specification' do
        request_template.operating_system = ''
        expect(request_template).to be_invalid
      end

      it 'is invalid with negative cpu_cores specifiation' do
        request_template.cpu_cores = -1
        expect(request_template).to be_invalid
      end

      it 'is invalid with too many cpu_cores ' do
        request_template.cpu_cores = Request::MAX_CPU_CORES + 1
        expect(request_template).to be_invalid
      end

      it 'is invalid with negative ram specifiation' do
        request_template.ram_gb = -1
        expect(request_template).to be_invalid
      end

      it 'is invalid with to much ram' do
        request_template.ram_gb = Request::MAX_RAM_GB + 1
        expect(request_template).to be_invalid
      end

      it 'is invalid with negative storage specifiation' do
        request_template.storage_gb = -1
        expect(request_template).to be_invalid
      end

      it 'is invalid with to much storage' do
        request_template.storage_gb = Request::MAX_STORAGE_GB + 1
        expect(request_template).to be_invalid
      end
    end
  end
end
