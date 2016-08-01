class User < ActiveRecord::Base
  has_secure_password

  validates_uniqueness_of :email,
                          case_sensitive: false,
                          allow_blank: false

  has_many :tasks,
           class_name: 'Task',
           foreign_key: :user_id,
           dependent: :restrict_with_exception
end
