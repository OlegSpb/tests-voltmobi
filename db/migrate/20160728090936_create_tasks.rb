class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :user_id

      t.string :name
      t.string :description
      t.string :state, default: 'new'

      t.timestamps
    end

    add_index :tasks, :user_id
  end
end
