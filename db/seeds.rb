# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

require 'sshkey'

User.create(email: 'user@user.de', password: '123456', first_name: 'Max', last_name: 'Mustermann', role: :user)
User.create(email: 'admin@admin.de', password: '123456', first_name: 'Ad', last_name: 'Min', role: :admin, ssh_key: SSHKey.generate.ssh_public_key)
employee = User.create(email: 'employee@employee.de', password: '123456', first_name: 'Wissenschaftlicher', last_name: 'Mitarbeiter', role: :employee)
Project.create(name: 'Awesome Project', description: 'Test Project Description', responsible_users: [employee])
OperatingSystem.create([{ name: 'CentOS 7' }, { name: 'SLES 11 SP3' }, { name: 'Ubuntu 18.04' }])
