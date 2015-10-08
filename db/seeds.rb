# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Plan.create! name: "Small", price: 100
Plan.create! name: "Medium", price: 250
Plan.create! name: "Large", price: 750
Plan.create! name: "Custom", price: 1000
