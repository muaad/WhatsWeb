class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.references :customer, index: true
      t.references :ticket, index: true
      t.references :account, index: true
      t.integer :rating
      t.string :comment
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
