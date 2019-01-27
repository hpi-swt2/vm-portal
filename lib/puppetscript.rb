# frozen_string_literal: true

module Puppetscript
  def self.node_script(name, admin_users, users)
    puppet_string = generic_node_script
    admins_string = generate_user_array(admin_users)
    users_string = generate_user_array(users)
    format(puppet_string, name, admins_string, users_string)
  end

  def self.name_script(name)
    puppet_script = generic_name_script
    format(puppet_script, name, name, name)
  end

  def self.generic_node_script
    <<~NODE_SCRIPT
      class node_$%s {
              $admins = [%s]
              $users = [%s]

              realize(Accounts::Virtual[$admins], Accounts::Sudoroot[$admins])
              realize(Accounts::Virtual[$users])
      }
    NODE_SCRIPT
  end

  def self.generic_name_script
    <<~NAME_SCRIPT
      node \'$%s\'{

          if defined( node_$%s) {
                      class { node_$%s: }
          }
      }
    NAME_SCRIPT
  end

  def self.generate_user_array(users)
    users.map! { |user| "\"#{user.first_name << '.' << user.last_name}\"" }
    users.join(', ')
  end
end
