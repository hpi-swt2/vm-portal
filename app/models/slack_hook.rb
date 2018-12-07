# frozen_string_literal: true

require 'uri'
require 'json'
require 'net/http'

class SlackHook < ApplicationRecord
  belongs_to :user

  def post_message(message)
    Net::HTTP.post(URI.parse(url), { text: message }.to_json, 'Content-Type': 'application/json')
  end
end
