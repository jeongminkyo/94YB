# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Wallet.create(current_money: 0, whole_money: 0)

role_list = ['user', 'member', 'manager', 'admin']
role_list.each do |role|
  Role.where(name: role).first_or_create
end

admin_user = User.create( email: 'admin@email.com', password: 'tlsrnd13!@', display_name: '관리자')
admin_user.add_role :admin