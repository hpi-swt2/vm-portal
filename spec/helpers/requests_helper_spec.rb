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
    expect(replace_whitespaces('Testing String')).to eq('testing-string')
  end

  it 'replaces special characters correctly' do
    expect(replace_whitespaces('Testing Test#! String')).to eq('testing-test-string')
  end

  it 'does not modify a string without whitespaces' do
    teststring = 'teststring'
    expect(replace_whitespaces(teststring)).to eq(teststring)
  end

  it 'converts mb to gb correctly' do
    megabyte = 9_000
    expect(mb_to_gb(megabyte)).to eq(9)
  end

  it 'converts gb to mb correctly' do
    gigabyte = 9
    expect(gb_to_mb(gigabyte)).to eq(9000)
  end
end
