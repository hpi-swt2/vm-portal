# frozen_string_literal: true

module Puppetscript
  def self.init_script(users)
    users_string = ''.dup
    users.each do |user|
      # "  " for identation
      users_string << user_script(user)
    end
    format(generic_init_script, users_string)
  end

  def self.node_script(name, admin_users, users)
    puppet_string = generic_node_script
    admins_string = generate_user_array(admin_users)
    users_string = generate_user_array(users)
    vm_name_with_underscores = self.repalce_dashes_with_underscores(name)
    format(puppet_string, vm_name_with_underscores, admins_string, users_string)
  end

  def self.name_script(name)
    puppet_script = generic_name_script
    vm_name_with_underscores = self.repalce_dashes_with_underscores(name)
    format(puppet_script, vm_name_with_underscores, vm_name_with_underscores, vm_name_with_underscores)
  end

  def self.generic_init_script
    <<~INIT_SCRIPT
      class accounts {
        %s
      }
    INIT_SCRIPT
  end

  def self.user_script(user)
    <<-USER_SCRIPT

  @accounts::virtual { '#{user.human_readable_identifier}':
    uid             =>  #{user.user_id},
    realname        =>  '#{user.first_name} #{user.last_name}',
    sshkeytype      =>  'ssh-rsa',
    sshkey          =>  '#{user.ssh_key.try(:sub!, 'ssh-rsa ', '')}'
  }
    USER_SCRIPT
  end

  def self.generic_node_script
    <<~NODE_SCRIPT
      class node_%s {
              INIT_SCRIPT$admins = [%s]
              $users = [%s]

              realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
              realize(Accounts::Virtual[$users])
      }
    NODE_SCRIPT
  end

  def self.generic_name_script
    <<~NAME_SCRIPT
      node \'%s\'{

          if defined( node_%s) {
                      class { node_%s: }
          }
      }
    NAME_SCRIPT
  end

  def self.generate_user_array(users)
    users = users.map { |user| "\"#{user.human_readable_identifier}\"" }
    users.join(', ')
  end

  def self.node_file_correct?(vm_name, contents)
    result =    contents.lines[0].chomp.eql?('class node_' + vm_name + ' {')
    result &&=  contents.lines[1].start_with?('        $admins = [')
    result &&=  contents.lines[2].start_with?('        $users = [')
    result &&=  contents.lines[4].chomp.eql?('        realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])')
    result &&=  contents.lines[5].chomp.eql?('        realize(Accounts::Virtual[$users])')
    result &&=  contents.lines[6].chomp.eql?('}')
    result
  end

  def self.read_node_file(vm_name, repository_path = puppet_script_path)
    path = File.join(repository_path, node_file_name(vm_name))
    values = { admins: [], users: [] }
    return values unless File.exist?(path)

    contents = File.open(path).read
    raise 'Unsupported Format' unless node_file_correct?(vm_name, contents)

    admins = contents.lines[1][/\[.*?\]/].delete('"[]').split(', ')
    users = contents.lines[2][/\[.*?\]/].delete('"[]').split(', ')
    values[:admins] = admins.map { |admin| User.from_mail_identifier(admin) }.compact
    values[:users] = users.map { |user| User.from_mail_identifier(user) }.compact
    values
  end

  def self.puppet_script_path
    GitHelper.repository_path
  end

  def self.init_file_name
    File.join(AppSetting.instance.puppet_init_path, 'init.pp')
  end

  def self.node_file_name(vm_name)
    File.join(AppSetting.instance.puppet_nodes_path, 'node-' + vm_name + '.pp')
  end

  def self.class_file_name(vm_name)
    File.join(AppSetting.instance.puppet_classes_path, vm_name + '.pp')
  end

  def self.init_path
    File.join(Puppetscript.puppet_script_path, AppSetting.instance.puppet_init_path)
  end

  def self.nodes_path
    File.join(Puppetscript.puppet_script_path, AppSetting.instance.puppet_nodes_path)
  end

  def self.classes_path
    File.join(Puppetscript.puppet_script_path, AppSetting.instance.puppet_classes_path)
  end

  def self.repalce_dashes_with_underscores(vm_name)
    vm_name.tr('-', '_')
  end

  def self.replace_underscores_with_dashes(vm_name)
    vm_name.tr('_', '-')
  end
end
