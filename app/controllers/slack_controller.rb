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

  def request_for_state(state)
    SlackAuthRequest.all.find do |each|
      each.state == state
    end
  end

  def authenticate_request(_code)
    post_params = { client_id: client_id, client_secret: 'aa3b8bbaa4fc75aab22d13adb6e53bab', code: parsed_params[:code],
                    redirect_uri: redirect_uri }

    begin
      answer = Net::HTTP.post_form(URI.parse('https://slack.com/api/oauth.access'), post_params)
      return JSON.parse(answer.body)
    rescue StandardError
      return { 'error' => 'Could not reach slack' }
    end
  end

  def check_slack_answer(answer)
    answer && !answer['error'] && answer['incoming_webhook'] && answer['incoming_webhook']['url']
  end

  def slack_answered(answer)
    if check_slack_answer(answer)
      current_user.slack_hooks.create url: answer['incoming_webhook']['url']
    else
      @error_message = 'Error while finishing the authentication: ' + answer['error'] + '\n'
      @error_message += 'Please inform your system administrator if this error occurs multiple times'
    end
  end

  def authenticate_slack_request
    request = request_for_state(parsed_params[:state])
    if !request || !parsed_params[:code]
      @error_message = 'Invalid request, please try authenticating slack again'
    else
      answer = authenticate_request parsed_params[:code]
      slack_answered(answer)
    end
  end

  def update
    if current_user
      authenticate_slack_request
    else
      redirect_to new_user_session_path, notice: 'You are not logged in.'
    end
  end

  def redirect_uri
    request.base_url + '/slack/auth'
  end

  def client_id
    '347447968560.478902469265'
  end

  private

  def parsed_params
    { code: params[:code], state: params[:state] }
  end
end
