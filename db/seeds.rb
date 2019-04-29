# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

OperatingSystem.create([{ name: 'CentOS 7' }, { name: 'SLES 11 SP3' }, { name: 'Ubuntu 18.04' }])

if AppSetting.all.empty?
  AppSetting.create({singleton_guard: 0,
                     github_user_name: 'MyUserName',
                     github_user_email: 'example@email.com',
                     git_repository_name: 'repository',
                     git_repository_url: 'https://github.com/hpi-swt2/vm-portal.git',
                     puppet_init_path: '/',
                     puppet_nodes_path: '/Node',
                     puppet_classes_path: '/Name',
                     vm_archivation_timeout: 3,
                     max_shown_vms: 10,
                     min_cpu_cores: 1,
                     max_cpu_cores: 64,
                     max_ram_size: 256,
                     max_storage_size: 1000})
end

