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
    system_text = "You are an assistant for an e-commerce website. 1. Always say the name of the product. 2. If you don't have any products at the end of this message, say we don't have that or you don't know.  Here are the products you should use to answer the user's questions: "
    nearest_products.each do |product|
      system_text += "** PRODUCT #{product.id}: name: #{product.name}, description: #{product.description} **"
    end
    results << { role: "system", content: system_text }
    questions.each do |question|
      results << { role: "user", content: question.user_question }
      results << { role: "assistant", content: question.ai_answer || "" }
    end

    return results
  end

  def nearest_products
    response = client.embeddings(
      parameters: {
        model: 'text-embedding-3-small',
        input: @question.user_question
      }
    )
    question_embedding = response['data'][0]['embedding']
    return Product.nearest_neighbors(
      :embedding, question_embedding,
      distance: "euclidean"
    ).limit(3)
  end
end
