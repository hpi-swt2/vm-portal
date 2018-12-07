# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :user do
    # https://github.com/stympy/faker/blob/master/doc/v1.9.1/internet.md#fakerinternet
    email { Faker::Internet.safe_email }
    password { Faker::Internet.password(min_length = 10, max_length = 20, mix_case = true, special_chars = true) }
    password_confirmation { password }
    first_name { 'Max' }
    last_name { 'Mustermann' }
    sshkey { 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9HuXvYJPtQE/o/7TYi63yAopsrJ6TP+lDGdyQ+nVVp+5ojAIy9h8/h99UlNxjkiFT2YhI3Fl/pgNDRO4PVo6tlgb3CwiAZjSdeE5RnF79Dkj5XsM4j+FLMoXtbRw0K9ok9RKjz6ygIs1JDmaOdXexFnq4nAYU3fSLUa6WoccqTHe8bFuJoAv1gbnx09Js8YcVMD96mpTJ3V/MK5YfIv10dbtrDhGug3IS1V2J+0BB9orbQja554N+4S0I9rFBgVCpvPmQqddDHd/AdGkLv/zjEfGytjnvp68bEfDinkQkPfuxw01yd5MbcvLv39VVICWtKbqW263HT5LvSxwKorR7' }
  end
end
