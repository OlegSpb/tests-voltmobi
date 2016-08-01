require "erb"

namespace :unicorn do

  desc 'Export unicorn config'
  task :export_config do
    on roles(fetch(:unicorn_roles)) do
      compiled = ERB.new(File.read(File.expand_path("../unicorn_config.rb.erb", __FILE__)), nil, '-').result(binding)

      upload! StringIO.new(compiled), "#{shared_path}/config/unicorn/#{fetch(:stage)}.rb"
    end
  end

end

before 'deploy:check:linked_files', 'unicorn:export_config'