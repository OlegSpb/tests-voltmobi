class CreateTaskAttachments < ActiveRecord::Migration
  def change
    create_table :task_attachments do |t|
      t.integer :task_id, null: false

      t.string :file, null: false

      t.timestamps
    end

    add_index :task_attachments, :task_id
  end
end
