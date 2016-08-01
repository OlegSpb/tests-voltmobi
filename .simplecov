SimpleCov.command_name "test:functionals"

SimpleCov.start 'rails' do
    add_group "Controllers", "app/controllers"
end