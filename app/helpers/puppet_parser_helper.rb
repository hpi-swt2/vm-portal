# frozen_string_literal: true

module PuppetParserHelper
  def self.node_file_correct?(vm_name, contents)
    result =    contents.lines[0].chomp.eql?('class node_$' + vm_name + ' {')
    result &&=  contents.lines[1].start_with?('        $admins = [')
    result &&=  !contents.lines[1].include?('[]')
    result &&=  contents.lines[2].start_with?('        $users = [')
    result &&=  contents.lines[4].chomp.eql?('        realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])')
    result &&=  contents.lines[5].chomp.eql?('        realize(Accounts::Virtual[$users])')
    result &&=  contents.lines[6].chomp.eql?('}')
    result
  end

  def self.read_node_file(vm_name, repository_path = puppet_script_folder)
    path = File.join(Rails.root, repository_path, 'Node', 'node-' + vm_name + '.pp')
    values = { 'admins' => [], 'users' => [] }
    if File.exist?(path)
      contents = File.open(path).read
      raise 'Unsupported Format' unless node_file_correct?(vm_name, contents)

      admins = contents.lines[1][/\[.*?\]/].delete('"[]').split(', ')
      users = contents.lines[2][/\[.*?\]/].delete('"[]').split(', ')
      admins.map! { |admin| User.from_mail_identifier(admin) }
      users.map! { |user| User.from_mail_identifier(user) }
      values['admins'] = admins
      values['users'] = users
    end
    values
  end

  def self.puppet_script_folder
    ENV['GIT_REPOSITORY_NAME']
  end

  def self.puppet_script_path
    File.join(Rails.root, puppet_script_folder)
  end
end
