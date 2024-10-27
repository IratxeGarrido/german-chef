# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Product.destroy_all

Product.create!(name: "Trousers", description: "A pair of bluejeans best suited for tall people.", price: 50)
Product.create!(name: "Shirt", description: "A white shirt with a pocket.", price: 20)
Product.create!(name: "Shoes", description: "A pair of black shoes.", price: 30)
Product.create!(name: "Hat", description: "A baseball cap.", price: 10)
Product.create!(name: "Chair", description: "A wooden chair.", price: 40)
Product.create!(name: "Table", description: "A metal table.", price: 60)
Product.create!(name: "Sofa", description: "A leather sofa.", price: 100)
Product.create!(name: "Bed", description: "A queen-sized bed.", price: 200)
