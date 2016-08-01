class Web::WelcomeController < Web::ApplicationController
  def index
    @tasks = ::Task.all.includes(:user)
  end
end
