# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user if it doesn't exist
puts "Creating admin user..."
admin = User.find_or_create_by(username: "admin") do |user|
  user.password = "admin123"  # In production, use a secure password or env variable
  puts "Admin user created"
end

puts "Seed data loaded successfully!"
