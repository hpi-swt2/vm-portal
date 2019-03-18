# frozen_string_literal: true

module Puppetscript
  def self.init_script(users)
    render_template 'initScript', binding
  end

  def self.node_script(vm_name, admins, users)
    render_template 'nodeScript', binding
  end

  def self.name_script(name)
    render_template 'nameScript', binding
  end

  # explicit parameter binding enables to capture parameters
  def self.render_template(template_name, binding)
    template = File.open('./lib/assets/' + template_name + '.erb', encoding: 'utf-8', &:read)
    ERB.new(template).result binding
  end

  def self.generate_user_array(users)
    users = users.map { |user| "\"#{user.human_readable_identifier}\"" }
    users.join(', ')
  end

  def self.node_file_correct?(vm_name, contents)
    result =    contents.lines[0].chomp.eql?('class node_' + replace_dashes_with_underscores(vm_name) + ' {')
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

  def self.replace_dashes_with_underscores(vm_name)
    vm_name.tr('-', '_')
  end

  def self.replace_underscores_with_dashes(vm_name)
    vm_name.tr('_', '-')
  end
end
