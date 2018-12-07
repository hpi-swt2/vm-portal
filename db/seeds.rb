# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
user = User.create(email: 'user@user.de', password: '123456', role: :user)
UserProfile.create(first_name: 'Max', last_name: 'Mustermann', user: user)
admin = User.create(email: 'admin@admin.de', password: '123456', role: :admin)
UserProfile.create(first_name: 'Ad', last_name: 'Min', user: admin)
wimi = User.create(email: 'wimi@wimi.de', password: '123456', role: :wimi)
UserProfile.create(first_name: 'Wissenschaftlicher', last_name: 'Mitarbeiter', user: wimi)