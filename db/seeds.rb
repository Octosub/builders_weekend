# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

=begin
Room.destroy_all

counter = 1

5.times do
  puts "creating room #{1}"
  Room.create!(name:Faker::Restaurant.name, description:Faker::Restaurant.description, url:Faker::Internet.domain_name )
  counter += 1
end

puts
puts "Rooms created"
=end
