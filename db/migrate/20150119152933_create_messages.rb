class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :text
      t.references :contact, index: true

      t.timestamps
    end
  end
end
