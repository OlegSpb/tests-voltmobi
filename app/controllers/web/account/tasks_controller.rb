class Web::Account::TasksController < Web::ApplicationController
  include NeedAuth

  before_action :load_tasks, only: [:index]
  before_action :load_task, except: [:index, :new, :create]


  def index

  end

  def new
    @task = ::Task.new()
  end

  def create
    if is_admin?
      @task = ::Task.new(task_params)
    else
      @task = current_user.tasks.build(task_params)
    end

    if @task.valid? && @task.save
      redirect_to account_task_path(@task) and return
    end

    render action: :new
  end

  def show
    @attachments = @task.attachments.order(id: :desc)
  end

  def edit

  end

  def update
    if @task.update_attributes(task_params)
      redirect_to action: :show and return
    end

    render action: :edit
  end

  def update_state
    change_state_event = params['to'].to_s

    unless Task.allowed_state_events.include?(change_state_event)
      render inline: 'Wrong event name!', content_type: 'text/plain', status: 400 and return
    end

    unless @task.send(change_state_event)
      render inline: 'State not updated!', content_type: 'text/plain', status: 403 and return
    end

    render layout: false
  end

  def destroy
    unless @task.present? && @task.destroy
      render nothing: true, status: 400 and return
    end

    respond_to do |format|
      format.js
      format.html { redirect_to account_tasks_path }
    end
  end

  private

  def task_params
    allowed_params = params.require('task').permit('name', 'description', 'user_id')
    allowed_params.delete('user_id') unless is_admin?

    allowed_params
  end

  def loaded_task
    @task
  end

  def load_task
    @task ||= tasks.where(id: params['id']).first

    unless @task.present?
      if request.xhr?
        render inline: 'Forbidden!', content_type: 'text/plain', status: 403 and return
      end

      render 'web/forbidden', status: 403 and return
    end
  end

  def load_tasks
    @tasks ||= tasks
  end


  def tasks
    return nil unless user_signed_in?

    if is_admin?
      ::Task.all.includes(:user)
    else
      current_user.tasks
    end
  end
end
