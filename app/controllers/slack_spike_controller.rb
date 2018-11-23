require 'uri'
require 'json'
require 'net/http'

class SlackSpikeController < ApplicationController
	def index
		@@state = 'foo'
		@state = state_with @@state
		render 'index'
	end

	def auth
		if @@state != parsed_params[:state]
			puts parsed_params[:state]
			puts @@state
			render 'error'	
			return;
		end

		post_params = {client_id: '347447968560.478902469265', client_secret: 'aa3b8bbaa4fc75aab22d13adb6e53bab', 
		 code: parsed_params[:code], redirect_uri: 'http://159.69.32.65:3000/slack/auth'}
		answer = Net::HTTP.post_form(URI.parse('https://slack.com/api/oauth.access'), post_params)
		puts 'start'
		puts answer.body
		post_slack 'Hello Björn', JSON.parse(answer.body)['incoming_webhook']['url']
		puts 'end'
		render 'auth'
	end

	private
	def post_slack (message, address)
		puts address
		Net::HTTP.post(URI.parse(address), {text: message}.to_json, 'Content-Type': 'appliction/json')
	end

	def state_with (string)
		'&state=' + string
	end

	def parsed_params
		{code: params[:code], state: params[:state]}
	end
end
