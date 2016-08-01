namespace :populate do

  desc 'Populate users'
  task :users => :environment do
    FactoryGirl.create_list(:user, rand(10))
  end

  desc 'Create users tasks'
  task :tasks => :environment do
    users = User.where(role: 'user').order('RANDOM()')

    if users.size > 0
      rand(10).times do
        u = users[rand(users.size)]
        FactoryGirl.create_list(:task, rand(5), user: u)
      end
    end
  end

  desc 'Create users tasks'
  task :attachments => :environment do
    tasks = Task.all.order('RANDOM()')

    if tasks.size > 0
      rand(20).times do
        FactoryGirl.create(:task_attachment, task: tasks[rand(tasks.size)])
      end
    end
  end

  desc 'Populate users, tasks and attachments'
  task :all => [:users, :tasks, :attachments] do

  end
end