# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the OperatingSystemsHelper. For example:
#
# describe OperatingSystemsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe OperatingSystemsHelper, type: :helper do
  describe 'operating_system_options' do
    it 'has a \'none\' selection of operating_systems as the first element' do
      options = operating_system_options
      expect(options).to include('none')
    end

    it 'has an \'other(write in Comment)\' selection of operating_systems as the last element' do
      options = operating_system_options
      expect(options).to include('other(write in Comment)')
    end

    it 'has names of created operating systems as elements' do
      operating_system = FactoryBot.create(:operating_system)
      options = operating_system_options
      expect(options).to include(operating_system.name)
    end
  end
end
