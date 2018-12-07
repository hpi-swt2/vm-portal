# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
ssh_key = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9HuXvYJPtQE/o/7TYi63yAopsrJ6TP+lDGdyQ+nVVp+5ojAIy9h8/h99UlNxjkiFT2YhI3Fl/pgNDRO4PVo6tlgb3CwiAZjSdeE5RnF79Dkj5XsM4j+FLMoXtbRw0K9ok9RKjz6ygIs1JDmaOdXexFnq4nAYU3fSLUa6WoccqTHe8bFuJoAv1gbnx09Js8YcVMD96mpTJ3V/MK5YfIv10dbtrDhGug3IS1V2J+0BB9orbQja554N+4S0I9rFBgVCpvPmQqddDHd/AdGkLv/zjEfGytjnvp68bEfDinkQkPfuxw01yd5MbcvLv39VVICWtKbqW263HT5LvSxwKorR7'
User.create(email: 'user@user.de', password: '123456', first_name: 'Max', last_name: 'Mustermann', role: :user)
User.create(email: 'admin@admin.de', password: '123456', first_name: 'Ad', last_name: 'Min', role: :admin, ssh_key: ssh_key)
User.create(email: 'wimi@wimi.de', password: '123456', first_name: 'Wissenschaftlicher', last_name: 'Mitarbeiter', role: :wimi)
OperatingSystem.create([{ name: 'CentOS 7' }, { name: 'SLES 11 SP3' }, { name: 'Ubuntu 18.04' }])
