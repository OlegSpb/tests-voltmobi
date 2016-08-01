class Web::Account::Task::AttachmentsController < Web::ApplicationController
  include NeedAuth

  before_action :load_task

  def new
    @attachment = @task.attachments.build
  end

  def create
    @attachment = @task.attachments.build(attachment_params)

    if @attachment.valid? && @attachment.save
      redirect_to account_task_path(@task) and return
    end

    render action: :new

  rescue ActionController::ParameterMissing
    render action: :new
  end

  private

  def attachment_params
    params.required('task_attachment').permit('file')
  end

  def load_task
    @task =
        if is_admin?
          ::Task.where(id: params['task_id']).includes(:user).first
        else
          current_user.tasks.where(id: params['task_id']).first
        end

    unless @task.present?
      render 'web/not_found', status: 404 and return
    end
  end
end
