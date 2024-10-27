class Product < ApplicationRecord
  has_neighbors :embedding
  after_create :set_embedding

  private

  def set_embedding
    client = OpenAI::Client.new
    response = client.embeddings(
      parameters: {
        model: 'text-embedding-3-small',
        input: "Product: #{name}. Description: #{description}"
      }
    )
    embedding = response['data'][0]['embedding']
    update(embedding: embedding)
  end
end
