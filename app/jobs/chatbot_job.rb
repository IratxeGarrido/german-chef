class ChatbotJob < ApplicationJob
  queue_as :default

  def perform(question)
    @question = question
    chaptgpt_response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: questions_formatted_for_openai
      }
    )
    new_content = chaptgpt_response["choices"][0]["message"]["content"]

    question.update(ai_answer: new_content)
    Turbo::StreamsChannel.broadcast_update_to(
      "question_#{@question.id}",
      target: "question_#{@question.id}",
      partial: "questions/question", locals: { question: question })
  end

  private

  def client
    @client ||= OpenAI::Client.new
  end

  def questions_formatted_for_openai
    questions = @question.user.questions
    results = []
    system_text = "You are a skilled German chef passionate about sharing culinary 
                  knowledge and expertise. Your goal is to teach people how to cook 
                  delicious and healthy meals, tailored to diverse dietary needs.
                  
                  Key considerations when creating recipes:
                  - Vegetarian: Exclude meat and poultry.
                  - Vegan: Exclude all animal products, including dairy, eggs, and honey.
                  - Gluten-Free: Avoid wheat, barley, and rye.
                  - Allergies: Be mindful of common allergens like nuts, dairy, eggs, 
                  soy, seafood, and specific fruits.
                  
                  When crafting recipes, please ensure:
                  - Clarity: Provide clear, step-by-step instructions.
                  - Accessibility: Use common ingredients and simple techniques.
                  - Flexibility: Offer alternative ingredients or substitutions to accommodate
                  various dietary needs.
                  - Nutritional Value: Prioritize balanced meals with a focus on fresh, 
                  seasonal produce."

    nearest_recipes.each do |recipe|
      system_text += "** RECIPE #{recipe.id}: name: #{recipe.name}, ingredients: #{recipe.ingredients} **"
    end
    results << { role: "system", content: system_text }
    questions.each do |question|
      results << { role: "user", content: question.user_question }
      results << { role: "assistant", content: question.ai_answer || "" }
    end

    return results
  end

  def nearest_recipes
    response = client.embeddings(
      parameters: {
        model: 'text-embedding-3-small',
        input: @question.user_question
      }
    )
    question_embedding = response['data'][0]['embedding']
    return Recipe.nearest_neighbors(
      :embedding, question_embedding,
      distance: "euclidean"
    ).limit(3)
  end
end
