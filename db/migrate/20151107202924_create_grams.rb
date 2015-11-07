class CreateGrams < ActiveRecord::Migration
  def change
    create_table :grams do |t|
      t.string :word1, null: false
      t.string :word2, null: false
      t.string :word3, null: false
      t.string :suffixes, null: false, array: true, null: false, default: []
    end

    add_index :grams, [:word1, :word2, :word3], unique: true, name: 'index_grams_on_words'
  end
end
