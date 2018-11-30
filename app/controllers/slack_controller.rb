# frozen_string_literal: true

require 'securerandom'
require 'net/http'
require 'json'
require 'uri'

class SlackController < ApplicationController
  def new
    if current_user
      @controller = self
      @request = current_user.slack_auth_requests.create state: SecureRandom.uuid
    else
      redirect_to new_user_session_path, notice: 'You are not logged in.'
    end
  end

  def update
    if current_user
      @request = SlackAuthRequest.all.find do |each|
        each.state == parsed_params[:state]
      end

      post_params = { client_id: client_id, client_secret: 'aa3b8bbaa4fc75aab22d13adb6e53bab', code: parsed_params[:code],
                      redirect_uri: redirect_uri }

      answer = Net::HTTP.post_form(URI.parse('https://slack.com/api/oauth.access'), post_params)
      answer = JSON.parse(answer.body)

      current_user.slack_hooks.create url: answer['incoming_webhook']['url']
    else
      redirect_to new_user_session_path, notice: 'You are not logged in.'
    end
  end

  def redirect_uri
    'https://098e671a.ngrok.io/slack/update'
  end

  def client_id
    '347447968560.478902469265'
  end

  private

  def parsed_params
    { code: params[:code], state: params[:state] }
  end
end
