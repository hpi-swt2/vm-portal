# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#

# Test users for different roles, usable in OpenID Testmode just comment in the user with the role you which to login with
# when clicking login with OAuth on Local Dev Server
# User.create(email: 'max.mustermann@student.hpi.de', first_name: 'Max', last_name: 'Mustermann', role: :user, uid: '123545')
# User.create(email: 'max.mustermann@student.hpi.de', first_name: 'Max', last_name: 'Mustermann', role: :employee, uid: '123545')
# User.create(email: 'max.mustermann@student.hpi.de', first_name: 'Max', last_name: 'Mustermann', role: :admin, uid: '123545')

OperatingSystem.create([{ name: 'CentOS 7' }, { name: 'SLES 11 SP3' }, { name: 'Ubuntu 18.04' }])
