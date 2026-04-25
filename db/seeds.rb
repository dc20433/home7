# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
# # Ensure your main account is always an admin after a reset
User.find_or_create_by!(email: "jz2043@yahoo.com") do |u|
    u.password = "11Danielz@"
    u.admin = true
end

# Check if the column exists before updating to avoid console errors
if user.respond_to?(:admin)
  user.update!(admin: true)
  puts "Admin access granted to jz2043@yahoo.com"
end
