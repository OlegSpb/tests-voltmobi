role :app, %w{reki@reki-travel.ru}
role :web, %w{reki@reki-travel.ru}
role :db,  %w{reki@reki-travel.ru}

set :deploy_to, '/home/reki/data/volt_mobi'
set :repo_url, './'
set :branch, 'master'

set :linked_files, fetch(:linked_files, [])
                       .push("db/#{fetch(:stage)}.sqlite3")

