# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the RequestsHelper. For example:
#
# describe RequestsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end

RSpec.describe RequestsHelper, type: :helper do
  it 'replaces whitespaces correctly' do
    expect(replace_whitespaces('Testing String')).to eq('Testing-String')
  end

  it 'replaces special characters correctly' do
    expect(replace_whitespaces('Testing Test#! String')).to eq('Testing-Test-String')
  end

  it 'does not modify a string without whitespaces' do
    teststring = 'TestString'
    expect(replace_whitespaces(teststring)).to eq(teststring)
  end
end
