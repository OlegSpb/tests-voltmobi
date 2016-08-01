class Task < ActiveRecord::Base

  validates_presence_of :name, :user, :user_id,
                        allow_blank: false

  belongs_to :user,
             class_name: 'User',
             foreign_key: :user_id

  has_many :attachments,
           class_name: 'TaskAttachment',
           foreign_key: :task_id,
           dependent: :destroy

  state_machine :initial => :new do

    event :start do
      transition :new => :started
    end

    event :done do
      transition :started => :finished
    end

    event :restart do
      transition :finished => :new
    end
  end

  def self.allowed_state_events
    @event_states ||= Task.new.state_paths.flatten.map{|s| s.event.to_s }
  end
end
