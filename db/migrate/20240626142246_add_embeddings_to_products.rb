class AddEmbeddingsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :embedding, :vector, limit: 1536
  end
end
