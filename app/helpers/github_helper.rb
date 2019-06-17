# frozen_string_literal: true

module GithubHelper
  
  def self.init
  	github = Github.new basic_auth: 'hart-bot:Still2hart4you!'
  	puts '#######################'
  	puts AppSetting.instance.github_user_name
  	puts AppSetting.instance.github_user_password
  end 

end