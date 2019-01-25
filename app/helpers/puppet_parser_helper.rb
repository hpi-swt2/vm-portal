# frozen_string_literal: true




module PuppetParserHelper
  def self.read_node_file(vm_name, repository_path = puppet_script_folder)
    path = File.join(Rails.root, repository_path, 'Node', 'node-' + vm_name + '.pp')
    contents = File.open(path).read
    contents.start_with?('class node_')

    unless contents.lines[0].chomp.eql?('class node_$' + vm_name + ' {') &&
           contents.lines[1].start_with?('        $admins = [') &&
           !contents.lines[1].include?('[]') &&
           contents.lines[2].start_with?('        $users = [') &&
           contents.lines[4].chomp.eql?('        realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])') &&
           contents.lines[5].chomp.eql?('        realize(Accounts::Virtual[$users])') &&
           contents.lines[6].chomp.eql?('}') then raise 'unsupported Format'
    end

    values = { 'admins' => [], 'users' => [] }
    admins = contents.lines[1][/\[.*?\]/].tr('\'[]', '').split(', ')
    users = contents.lines[2][/\[.*?\]/].tr('\'[]', '').split(', ')

    admins.map! { |admin| User.from_mail_identifier(admin) }
    users.map! { |user| User.from_mail_identifier(user) }
    values['admins'] = admins
    values['users'] = users
    values
  end

  def self.puppet_script_folder
    'puppet_scripts'
  end

  def self.puppet_script_path
    File.join(Rails.root, puppet_script_folder)
  end
end
