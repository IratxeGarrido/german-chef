require "json"

puts "Destroying all questions..."
Question.destroy_all

puts "Destroying all recipes..."

Recipe.destroy_all

filepath = File.join(Rails.root, "db", "","recipes.json")

if File.exist?(filepath)
  serialized_recipes = File.read(filepath)
  recipes = JSON.parse(serialized_recipes)
  recipes.each do |recipe|
    Recipe.create!(
      name: recipe["Name"], 
      url: recipe["Url"], 
      instructions: recipe["Instructions"], 
      ingredients: recipe["Ingredients"]
    )
  end

  puts "Seeding completed successfully."
else
  puts "Seed file not found: #{filepath}"
end