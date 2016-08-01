class TaskAttachment < ActiveRecord::Base
  belongs_to :task,
             class_name: 'Task',
             foreign_key: :task_id

  mount_uploader :file, AttachmentUploader

  validates_presence_of :file
end
